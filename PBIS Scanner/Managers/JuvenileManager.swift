// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

class JuvenileManager: ObservableObject, APIManagerInjector, KeychainManagerInjector {

    // MARK: Observe

    @Published private var observationToken: AnyCancellable?

    // MARK: Properties

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
//        observe(entity: Behavior.self)
//        observe(entity: Location.self)
        localFetch { (behaviors: [Behavior]) in
            if !behaviors.isEmpty {
                self.behaviors = behaviors
            } else {
                remoteFetch { (behaviors: [Behavior]) in
                    behaviors.forEach({ behavior in
                        self.save(entity: behavior)
                        self.behaviors.append(behavior)
                    })
                }
            }
        }

        localFetch { (locations: [Location]) in
            if !locations.isEmpty {
                self.locations = locations
            } else {
                remoteFetch(Location.self, withType: String.self) { (strings: [String]) in
                    strings.forEach({ name in
                        let location = Location(name: name)
                        self.locations.append(location)
                        self.save(entity: location)
                    })
                }
            }
        }
    }
}

// MARK: Helper Methods

extension JuvenileManager {
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

// MARK: Remote Fetch

extension JuvenileManager {
    func remoteFetch<T: Model, U: Decodable>(_ model: T.Type, withType atomic: U.Type, customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([U]) -> Void) {
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

    func remoteFetch<T: Model>(customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([T]) -> Void) {
        var endpointConfig: EndpointConfiguration! = customEndpoint

        switch T.self {
        case is Juvenile.Type:
            endpointConfig = juvenilesEndpointConfig
        case is Behavior.Type:
            endpointConfig = behaviorsEndpointConfig
        default:
            print("Could not configure endpoint for type \(T.modelName).")
            return
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

// MARK: Local Fetch

extension JuvenileManager {
    // TODO: Unsure if these work
    func observe<T: Model>(entity: T.Type) {
        observationToken = Amplify.DataStore.publisher(for: T.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
            }) { event in
                guard let object = try? event.decodeModel(as: T.self) else { return }

                switch DataStoreMutationType(rawValue: event.mutationType) {
                case .create:
                    if let behavior = object as? Behavior {
                        self.behaviors.append(behavior)
                    } else if let location = object as? Location {
                        self.locations.append(location)
                    }
                case .delete:
                    if let behavior = object as? Behavior,
                        let index = self.behaviors.firstIndex(of: behavior){
                        self.behaviors.remove(at: index)
                    } else if let location = object as? Location,
                        let index = self.locations.firstIndex(of: location){
                        self.locations.remove(at: index)
                    }
                default:
                    print("Mutation type does not exist?")
                }
        }
    }
    
    func localFetch<T: Model>(completion: ([T]) -> Void) {
        Amplify.DataStore.query(T.self) { result in
            switch result {
            case .success(let objects):
                completion(objects)
            case .failure(let error):
                print(error)

            }
        }
    }
    
//    func localFetchForJuvenileWithEventID(_ id: String, completion: (Juvenile?) -> Void) {
//        let p = Juvenile.keys
//        Amplify.DataStore.query(Juvenile.self, where: p.event_id == id, completion: { result in
//            switch result {
//            case .success(let juveniles):
//                if let juvenile = juveniles.first {
//                    completion(juvenile)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        })
//    }

//    func locallFetchForJuvenileQueueWithEventIDArray(_ data: Data? = nil, completion: ([Juvenile]) -> Void) {
////        guard
////            let data = data,
////            let array = try? JSONDecoder().decode([String].self, from: data)
////        else { return }
//
//        let array: [Int] = [10010]
//
//        save(entity: Juvenile(first_name: "fgdfg", last_name: "schreiber", points: 100, event_id: 10010, active: 0))
//
//        let p = Juvenile.keys
//        Amplify.DataStore.query(Juvenile.self, where: , sort: .ascending(Juvenile.keys.first_name)) { result in
//            switch result {
//            case .success(let juveniles):
//                completion(juveniles)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
}

// MARK: Saving & Deleting - Private!

extension JuvenileManager {
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
