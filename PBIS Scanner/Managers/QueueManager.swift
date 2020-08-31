// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class QueueManager: ObservableObject, APIManagerInjector, KeychainManagerInjector {

    // MARK: Observe

    @Published private var observationToken: AnyCancellable?

    // MARK: Properties

    private var queue: Queue!

    @Published var juveniles = [Juvenile]()

    @Published var behaviors = [Behavior]()

    @Published var locations = [Location]()

    // MARK: Initializers
    
    let behaviorsEndpointConfig = EndpointConfiguration(path: .behavior,
                                                        httpMethod: .get,
                                                        body: nil,
                                                        queryStrings: nil)
    
    let locationsEndpointConfig = EndpointConfiguration(path: .location,
                                                        httpMethod: .get,
                                                        body: nil,
                                                        queryStrings: nil)
    
    let juvenilesEndpointConfig = EndpointConfiguration(path: .juvenile(.get),
                                                        httpMethod: .get,
                                                        body: nil,
                                                        queryStrings: nil)

    init() {
        initializeQueue()
        initializeBehaviors()
        initializeLocations()
        observeJuveniles()
    }

    private func initializeQueue() {
        localFetch { (queues: [Queue]) in
            if !queues.isEmpty {
                print("\(queues.count) queues are on-device", "\(queues.first!.juveniles!.count) juveniles inside.")
                self.queue = queues.first!

                self.queue.juveniles?.load({ result in
                    switch result {
                    case .success(let juveniles):
                        DispatchQueue.main.async { self.juveniles = juveniles }
                    case .failure(let error):
                        print(error)
                    }
                })
            } else {
                self.queue = Queue(id: keychainManager.createUniqueID(), juveniles: [])
                save(entity: queue)
            }
        }
    }

    private func initializeLocations() {
        localFetch { (locations: [Location]) in
            if !locations.isEmpty {
                self.locations = locations
            } else {
                remoteFetch(Location.self, withType: String.self) { (strings: [String]) in
                    print("Attempted to remote fetch locations: ", strings)
                    strings.forEach({ name in
                        let location = Location(name: name)
                        self.locations.append(location)
                        self.save(entity: location)
                    })
                }
            }
        }
    }

    private func initializeBehaviors() {
        localFetch { (behaviors: [Behavior]) in
            if !behaviors.isEmpty {
                self.behaviors = behaviors
            } else {
                remoteFetch { (behaviors: [Behavior]) in
                    print("Attempted to remote fetch behaviors: ", behaviors)
                    behaviors.forEach({ behavior in
                        self.save(entity: behavior)
                        self.behaviors.append(behavior)
                    })
                }
            }
        }
    }
}

// MARK: Helper Methods

extension QueueManager {
    func clearAllData() {
        Amplify.DataStore.clear { result in
            switch result {
            case .success:
                print("Successfully cleared DataStore.")
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: Remote Fetch - Private!

extension QueueManager {
    /// Use this remote fetch function if the object return type is expected to be an atomic array and there are no special parameters. Location is likely to be the only endpoint in need of this treatment.
    private func remoteFetch<T: Model, U: Decodable>(_ model: T.Type, withType atomic: U.Type, customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([U]) -> Void) {
        var endpointConfig: EndpointConfiguration! = customEndpoint

        switch T.self {
        case is Location.Type:
            endpointConfig = locationsEndpointConfig
        default:
            print("Could not configure endpoint for type \(model.modelName).")
            return
        }

        apiManager.fetch(from: endpointConfig) { (result: Result<[U], ResponseError>) in
            switch result {
            case .success(let objects):
                completion(objects)
            case .failure(let error):
                completion([])
                print(error)
            }
        }
    }

    /// Use this remote fetch function if the object return type is not expected to be an array and there might special parameters.
    private func remoteFetch<T: Model>(customEndpoint: EndpointConfiguration? = nil, completion: @escaping (T?) -> Void) {
        var endpointConfig: EndpointConfiguration! = customEndpoint

        if endpointConfig == nil {
            switch T.self {
            case is Juvenile.Type:
                endpointConfig = juvenilesEndpointConfig
            case is Behavior.Type:
                endpointConfig = behaviorsEndpointConfig
            default:
                print("Could not configure endpoint for type \(T.modelName).")
                return
            }
        }

        apiManager.fetch(from: endpointConfig) { (result: Result<T?, ResponseError>) in
            switch result {
            case .success(let object):
                completion(object)
            case .failure(let error):
                completion(nil)
                print(error)
            }
        }
    }

    /// Use this remote fetch function if the object return type is expected to be an array and there are no special parameters.
    private func remoteFetch<T: Model>(completion: @escaping ([T]) -> Void) {
        var endpointConfig: EndpointConfiguration!

        if endpointConfig == nil {
            switch T.self {
            case is Juvenile.Type:
                endpointConfig = juvenilesEndpointConfig
            case is Behavior.Type:
                endpointConfig = behaviorsEndpointConfig
            default:
                print("Could not configure endpoint for type \(T.modelName).")
                return
            }
        }

        apiManager.fetch(from: endpointConfig) { (result: Result<[T], ResponseError>) in
            switch result {
            case .success(let objects):
                completion(objects)
            case .failure(let error):
                completion([])
                print(error)
            }
        }
    }
}

// MARK: Local Fetch - Private!

extension QueueManager {
    private func observeJuveniles() {
        observationToken = Amplify.DataStore.publisher(for: Juvenile.self)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            }) { changes in
                guard let juvenile = try? changes.decodeModel(as: Juvenile.self) else { return }
                switch DataStoreMutationType(rawValue: changes.mutationType) {
                case .create:
                    if !self.queue.juveniles!.contains(juvenile) {
                        DispatchQueue.main.async { self.juveniles.append(juvenile) }
                    }
                // TODO: Add juvenile removal capabillity
                case .delete:
                    print("Hit delete case.")
                case .update:
                    if let index = self.juveniles.firstIndex(of: juvenile) {
                        DispatchQueue.main.async { self.juveniles[index] = juvenile }
                    }
                default:
                    print("Hit default case.")
                }
        }
    }
    
    private func localFetch<T: Model>(predicate: QueryPredicate? = nil, sort: QuerySortInput? = nil, completion: ([T]) -> Void) {
        Amplify.DataStore.query(T.self, where: predicate, sort: sort) { result in
            switch result {
            case .success(let objects):
                completion(objects)
            case .failure(let error):
                print(error)

            }
        }
    }
}

// MARK: Saving & Deleting - Private!

extension QueueManager {
    private func save<T: Model>(entity: T) {
        Amplify.DataStore.save(entity) { result in
            switch result {
            case .success(let object):
                print("\(object.modelName) successfully saved to disk.")
            case .failure(let error):
                print(error)
            }
        }
    }

    private func delete<T: Model>(entity: T) {
        Amplify.DataStore.delete(entity) { result in
            switch result {
            case .success:
                print("Successfully deleted \(entity.modelName) from disk.")
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: Blend Fetch

extension QueueManager {
    func saveJuvenile(withEventID id: Int) {
        let p = Juvenile.keys
        localFetch(predicate: p.event_id.eq(id), sort: nil) { (juveniles: [Juvenile]) in
            if !juveniles.contains(where: { $0.event_id == id }) {
                let customEndpoint = EndpointConfiguration(path: .juvenile(.get),
                                                           httpMethod: .get,
                                                           body: nil,
                                                           queryStrings: [Juvenile.keys.event_id.stringValue: String(id)])

                remoteFetch(customEndpoint: customEndpoint) { (juvenile: Juvenile?) in
                    if var juvenile = juvenile {
                        juvenile.queue = self.queue
                        self.save(entity: juvenile) // CREATE
                    } else {
                        print("Could not find juvenile from database with event ID \(id)")
                    }
                }
            } else if var juvenile = juveniles.first {
                juvenile.queue = self.queue
                save(entity: juvenile) // UPDATE
                print("Fetched \(juvenile.first_name) from local and updated his/her queue.")
            }
        }
    }
}
