// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class JuvenileManager: ObservableObject, APIManagerInjector, NetworkManagerInjector {

    // MARK: Properties

    var juveniles = [Juvenile]()
    @Published var queueVerbalUpdate = ""
    private var juvenilesSubscription: AnyCancellable?

    weak var bucketManagerDelegate: BucketManager?

    private let dispatchGroup = DispatchGroup()
    private let dispatchQueue = DispatchQueue(label: "com.juvenileManager", qos: .userInitiated)

    // MARK: Initializers

    init() {
        initializeQueue()
        juvenilesSubscription = subscribeToJuveniles()
    }

    deinit {
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
                        print("create")
                        guard juvenile.isEnqueued else { break }
                        self.juveniles.append(juvenile)
                        DispatchQueue.main.async { self.queueVerbalUpdate = "\(juvenile.first_name) was added!" }
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
                            if !self.juveniles.contains(juvenile) {
                                self.juveniles.append(juvenile)
                                DispatchQueue.main.async { self.queueVerbalUpdate = "\(juvenile.first_name) was added!" }
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
    func initializeQueue() {
        self.apiManager.offlineFetch { (juveniles: [Juvenile]) in
            for juvenile in juveniles {
                if juvenile.isEnqueued {
                    self.juveniles.append(juvenile)
                }
            }
        }
    }

    func fetchJuveniles(withEventID id: Int? = nil) {
        var localFetch: [Juvenile] = []
        var didFind = false

        defer {
            if networkManager.isConnected {
                apiManager.fetchOnlineList { (remotes: [Juvenile]) in
                    if !didFind, var interest = remotes.first(where: { $0.event_id == id }) {
                        interest.isEnqueued = true
                        self.apiManager.save(entity: interest)
                    }
//                    if !ProcessInfo.processInfo.isLowPowerModeEnabled {
//                        DispatchQueue.global(qos: .background).async {
//                            // Flush non-existent juveniles.
//                            guard !remotes.isEmpty else { return }
//                            localFetch.forEach({ local in
//                                if !remotes.contains(local) {
//                                    self.apiManager.delete(entity: local)
//                                }
//                            })
//                        }
//                    }
                }
            } else { // Look for juveniles offline if no network connection found.
                apiManager.offlineFetch { (locals: [Juvenile]) in
                    localFetch = locals
                    locals.forEach({ local in
                        if local.event_id == id {
                            var new = local
                            new.isEnqueued = true
                            self.apiManager.save(entity: new)
                            return
                        }
                    })
                }
            }
        }

        guard let id = id, networkManager.isConnected else { return }
        let querySingleJuvenileEndpoint = EndpointConfiguration(path: .juvenile(.get), httpMethod: .get, body: nil, queryStrings: ["event_id": "\(id)"])
        apiManager.fetchOnlineObject(customEndpoint: querySingleJuvenileEndpoint) { (juvenile: Juvenile?) in
            if var juvenile = juvenile {
                juvenile.isEnqueued = true
                self.apiManager.save(entity: juvenile) { didSave in
                    didFind = true
                }
            }
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

        self.bucketManagerDelegate?.attemptToPushPosts()
    }
}
