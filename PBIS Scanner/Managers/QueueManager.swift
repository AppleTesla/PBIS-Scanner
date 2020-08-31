// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class QueueManager: ObservableObject, APIManagerInjector {

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
        initializeLocations()
        initializeBehaviors()
        fetchJuvenilesWithOnlinePriority()
    }

    /// This function loads juveniles into the queue from local only.
    private func initializeQueue() {
        offlineFetch { (queues: [Queue]) in
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
                self.queue = Queue(juveniles: [])
                save(entity: queue)
            }
        }
    }

    private func initializeLocations() {
        offlineFetch { (locations: [Location]) in
            if !locations.isEmpty {
                self.locations = locations
            } else {
                fetchOnlineAtomic(Location.self, withType: String.self) { (strings: [String]) in
                    print("Attempted to remote fetch locations on init: ", strings.count)
                    strings.forEach({ name in
                        let location = Location(id: String(name.hashValue), name: name)
                        if !self.locations.contains(location) {
                            self.locations.append(location)
                        }
                        self.save(entity: location)
                    })
                }
            }
        }
    }

    private func initializeBehaviors() {
        offlineFetch { (behaviors: [Behavior]) in
            if !behaviors.isEmpty {
                self.behaviors = behaviors
            } else {
                fetchOnlineList { (behaviors: [Behavior]) in
                    print("Attempted to remote fetch behaviors on init: ", behaviors.count)
                    behaviors.forEach({ behavior in
                        if !self.behaviors.contains(behavior) {
                            self.behaviors.append(behavior)
                        }
                        self.save(entity: behavior)
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
    private func fetchOnlineAtomic<T: Model, U: Decodable>(_ model: T.Type, withType atomic: U.Type, customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([U]) -> Void) {
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
    private func fetchOnlineObject<T: Model>(customEndpoint: EndpointConfiguration? = nil, completion: @escaping (T?) -> Void) {
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
    private func fetchOnlineList<T: Model>(completion: @escaping ([T]) -> Void) {
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
    private func offlineFetch<T: Model>(predicate: QueryPredicate? = nil, sort: QuerySortInput? = nil, completion: ([T]) -> Void) {
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

// MARK: Juvenile Fetch & Deletion

extension QueueManager {
    /// Fetching from a remote database will be prioritized. Avoid using this in common scenarios, as it can be slow and unpredictable.
    func fetchJuvenilesWithOnlinePriority(withEventID id: Int? = nil) {
        fetchOnlineList { (remotes: [Juvenile]) in
            /// Fetch all remote juveniles
            remotes.forEach({ remote in
                print(remote.event_id)
                self.save(entity: remote)
            })
            
            /// Fetch all local juveniles
            self.offlineFetch { (locals: [Juvenile]) in
                locals.forEach({ local in
                    /// If the local juvenile is non-existent or outdated when compared to remote, delete them.
                    if self.apiManager.networkManager.isConnected
                        && !remotes.isEmpty
                        && !remotes.contains(local) {
                        guard let index = self.juveniles.firstIndex(of: local) else { return }
                        self.juveniles.remove(at: index)
                        self.delete(entity: local)
                        /// If the local juvenile is intended to be added to the queue, do so here.
                    } else if let id = id, let interest = locals.first(where: { $0.event_id == id }) {
                        var new = interest
                        new.queue = self.queue
                        /// If local contains non-existent or outdated juveniles, delete them.
                        guard !self.juveniles.contains(new) else { return }
                        self.juveniles.append(new)
                        self.save(entity: new)
                    }
                })
            }
        }
    }

    /// Fetching from on-device location will be prioritized. Use this in common scenarios, as it is optimized for speed and efficiency.
    func fetchJuvenilesWithOfflinePriority(withEventID id: Int? = nil) {
        var shouldFetchOnline = true

        defer {
            /// Wait for offline fetch attempt..
            if shouldFetchOnline, let id = id {
                let customEndpoint = EndpointConfiguration(path: .juvenile(.get),
                                                           httpMethod: .get,
                                                           body: nil,
                                                           queryStrings: [Juvenile.keys.event_id.stringValue: String(id)])

                /// If the offline fetch failed, then try an online fetch.
                fetchOnlineList { (remotes: [Juvenile]) in
                    remotes.forEach({ remote in
                        if remote.event_id == id {
                            var new = remote
                            new.queue = self.queue

                            guard !self.juveniles.contains(new) else { return }
                            self.juveniles.append(new)
                            self.save(entity: new)
                            print("Successfully fetched \(new.first_name) from remote!")
                        } else {
                            self.save(entity: remote)
                        }
                    })
                }
            }
        }

        /// Look for juveniles offline first.
        offlineFetch { (locals: [Juvenile]) in
            locals.forEach({ local in
                /// Check for juvenile with scanned qr code string.
                if local.event_id == id {
                    shouldFetchOnline = false
                    var new = local
                    new.queue = self.queue

                    guard !self.juveniles.contains(new) else { return }
                    self.juveniles.append(new)
                    save(entity: new)
                }
            })
        }
    }

    func removeJuveniles(at offsets: IndexSet) {
        var juveniles = self.juveniles
        juveniles.remove(atOffsets: offsets)
        guard var juvenile = Set(juveniles).symmetricDifference(self.juveniles).first else { return }
        DispatchQueue.main.async { self.juveniles.remove(atOffsets: offsets) }
        juvenile.queue = nil
        save(entity: juvenile)
    }
}
