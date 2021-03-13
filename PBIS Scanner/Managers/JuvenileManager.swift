// MARK: Imports

import Foundation
import AVFoundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class JuvenileManager: ObservableObject, APIManagerInjector, NetworkManagerInjector {

    // MARK: Properties

    var juveniles = [Juvenile]()
    @Published var queueVerbalUpdate = ""
    private var juvenilesSubscription: AnyCancellable?

    var bucketManagerDelegate: BucketManager?
    private var networkCancellable: AnyCancellable?

    private let dispatchGroup = DispatchGroup()
    private let dispatchQueue = DispatchQueue(label: "com.juvenileManager", qos: .userInitiated)

    // MARK: Initializers

    init() {
        self.fetchAllJuveniles {
            apiManager.offlineFetch { (locals: [Juvenile]) in
                for local in locals {
                    if local.isEnqueued, local.active == 1 {
                        self.juveniles.append(local)
                    }
                }
            }
        }

        juvenilesSubscription = subscribeToJuveniles()
        networkCancellable = networkManager.$isConnected.sink { isConnected in
            if isConnected { self.fetchAllJuveniles { } }
        }
    }

    deinit {
        networkCancellable?.cancel()
        juvenilesSubscription?.cancel()
    }

    private func subscribeToJuveniles() -> AnyCancellable {
        Amplify.DataStore.publisher(for: Juvenile.self)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    print("Subscription received error - \(error.localizedDescription)")
                }
            }, receiveValue: { changes in
                self.dispatchQueue.async(group: self.dispatchGroup) {
                    self.dispatchGroup.enter()
                    guard let juvenile = try? changes.decodeModel(as: Juvenile.self) else { return }
                    switch DataStoreMutationType(rawValue: changes.mutationType) {
                    case .create:
                        print("created: ", juvenile)
                        guard juvenile.isEnqueued, juvenile.active == 1 else { break }
                        self.juveniles.append(juvenile)
                        DispatchQueue.main.async { self.queueVerbalUpdate = "\(juvenile.first_name) was added!" }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        self.dispatchGroup.leave()
                    case .delete:
                        if let index = self.juveniles.firstIndex(of: juvenile) {
                            self.juveniles.remove(at: index)
                            DispatchQueue.main.async { self.queueVerbalUpdate = "\(juvenile.first_name) was removed!" }
                            self.dispatchGroup.leave()
                        }
                    case .update:
                        if juvenile.isEnqueued {
                            // Add to queue
                            if !self.juveniles.contains(juvenile), juvenile.active == 1 {
                                self.juveniles.append(juvenile)
                                DispatchQueue.main.async { self.queueVerbalUpdate = "\(juvenile.first_name) was added!" }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                self.dispatchGroup.leave()
                                // Already in queue
                            } else if let index = self.juveniles.firstIndex(of: juvenile) {
                                self.juveniles[index] = juvenile
                                self.dispatchGroup.leave()
                            }
                        } else if let index = self.juveniles.firstIndex(of: juvenile) {
                            self.juveniles.remove(at: index)
                            self.dispatchGroup.leave()
                        }
                    default:
                        self.dispatchGroup.leave()
                        break
                    }
                }
            }
            )
    }
}

// MARK: Juvenile Fetch

extension JuvenileManager {
    func fetchJuvenile(withEventID id: Int? = nil, completion: @escaping (Result<Int, Error>) -> Void) {
        var isActive = 1
        
        defer {
            if let id = id {
                apiManager.offlineFetch { (locals: [Juvenile]) in
                    for var local in locals {
                        if local.event_id == id {
                            local.isEnqueued = true
                            self.apiManager.save(entity: local)
                            break
                        }
                    }
                }
            }
        }
        
        guard let id = id, networkManager.isConnected else { return }
        let querySingleJuvenileEndpoint = EndpointConfiguration(path: .juvenile(.get), httpMethod: .get, body: nil, queryStrings: ["event_id": "\(id)"])
        apiManager.fetchOnlineObject(customEndpoint: querySingleJuvenileEndpoint) { (juvenile: Juvenile?) in
            if juvenile != nil, var juvenile = juvenile {
                if (juvenile.active == 0) {
                    self.queueVerbalUpdate = "Do you want to reactivate \(juvenile.first_name)?"
                    isActive = 0
                } else {
                    juvenile.isEnqueued = true
                }
                                
                self.apiManager.save(entity: juvenile) { _ in
                    completion(.success(isActive))
                }
            }
        }
        
        completion(.failure(NSError(domain: "jvm", code: 0, userInfo: nil)))
    }
    
    private func fetchAllJuveniles(completion: () -> Void) {
        guard networkManager.isConnected else { return }
        
        defer { completion() }

        apiManager.fetchOnlineList { (remotes: [Juvenile]) in
            guard !remotes.isEmpty else { return }
            remotes.forEach({ remote in
                if (remote.active == 1) {
                    self.apiManager.save(entity: remote)
                }
            })
        }
    }
}

// MARK: Juvenile Deletion

extension JuvenileManager {
    func removeJuvenile(juvenile: Juvenile) {
        var juvenile = juvenile
        juvenile.isEnqueued = false
        apiManager.save(entity: juvenile)
        DispatchQueue.main.async {
            self.queueVerbalUpdate = "\(juvenile.first_name) was removed."
        }
    }

    func removeAllJuveniles() {
        for case var juvenile in juveniles {
            juvenile.isEnqueued = false
            self.apiManager.save(entity: juvenile)
        }
        DispatchQueue.main.async {
            self.queueVerbalUpdate = "Queue is emptied."
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    func clearFromDataStore() {
        Amplify.DataStore.query(Juvenile.self) {
            switch $0 {
            case .success(let juveniles):
                // result will be of type [Post]
                juveniles.forEach({ _ = Amplify.DataStore.delete($0) })
            case .failure(let error):
                print("Error on query() for type Juvenile - \(error.localizedDescription)")
            }
        }
    }
}

extension JuvenileManager {
    func activateJuvenileWithId(eventId: Int? = nil) {
        guard let eventId = eventId, networkManager.isConnected else { return }
        
        var activateJuvenileEndpoint: EndpointConfiguration!
        var id: String? = nil
            
        defer {
            if let id = id, let body = try? JSONSerialization.data(withJSONObject: [
                "event_id": "\(eventId)",
                "juvenile_id": "\(id)"
            ], options: []) {
                
                
                activateJuvenileEndpoint = EndpointConfiguration(path: .juvenile(.activate),
                                                                 httpMethod: .put,
                                                                 body: body,
                                                                 queryStrings: nil)
                apiManager.request(from: activateJuvenileEndpoint) { (result: Result<Juvenile, ResponseError>) in
                    switch result {
                    case .success(var juvenile):
                        self.fetchJuvenile(withEventID: juvenile.event_id) { (result: Result <Int, Error>) in
                            switch result {
                            case .success(_):
                                juvenile.isEnqueued = true
                                self.apiManager.save(entity: juvenile)
                            default:
                                return
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
                            
        apiManager.offlineFetch { (locals: [Juvenile]) in
            for local in locals {
                if local.event_id == eventId {
                    id = local.id
                }
            }
        }
    }
}

// MARK: Juvenile History
extension JuvenileManager {
    func getHistoryForJuvenile(_ juvenile: Juvenile) {
        let transactionsEndpointConfig = EndpointConfiguration(path: .juvenile(.transactions),
                                                               httpMethod: .get,
                                                               body: nil,
                                                               queryStrings: ["juvenile_id": "\(juvenile.id)"])
        apiManager.fetchOnlineList(customEndpoint: transactionsEndpointConfig) { (transactions: [Purchase]) in
            print(transactions)
        }
    }
}


// MARK: Juvenile Post

extension JuvenileManager {
    func saveToBucket(with behavior: Behavior?, for juveniles: [Juvenile]) {
        guard let behavior = behavior else { return }

        for juvenile in juveniles {
            self.removeJuvenile(juvenile: juvenile)
            let post = Post(juvenile_id: juvenile.id, behavior_id: behavior.id)
            self.apiManager.save(entity: post)
        }
        
        AudioServicesPlaySystemSound(1407)
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        self.bucketManagerDelegate?.attemptToPushPosts()
    }
}
