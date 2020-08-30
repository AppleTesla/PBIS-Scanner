// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

class JuvenileManager: ObservableObject, APIManagerInjector {
    
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

    let rewardsEndpointConfig = EndpointConfiguration(path: .reward,
                                                        httpMethod: .get,
                                                        body: nil,
                                                        queryStrings: nil)

    init() {
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

// MARK: Remote

extension JuvenileManager {
    private func remoteFetchWithStringType(_ type: Model.Type, customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([String]) -> Void) {
        var endpointConfig: EndpointConfiguration! = customEndpoint

        switch type.self {
        case is Location.Type:
            endpointConfig = locationsEndpointConfig
        default:
            print("Could not configure endpoint for type \(type.modelName).")
            return
        }

        apiManager.fetch(from: endpointConfig) { (result: Result<[String], ResponseError>) in
            switch result {
            case .success(let strings):
                completion(strings)
            case .failure(let error):
                completion([])
                print(error)
            }
        }
    }

    private func remoteFetch<T: Model>(customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([T]) -> Void) {
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

// MARK: Local

extension JuvenileManager {
    func observeJuveniles() {
        Amplify.DataStore.publisher(for: Juvenile.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
            }) { event in
                switch DataStoreMutationType(rawValue: event.mutationType) {
                case .create:
                    print("dsfdsf")
                case .delete:
                    print("dsfdsf")
                default:
                    print("Mutation type does not exist?")
                }
        }
    }
    
    func localFetch<T: Model>(completion: ([T]) -> Void) {
        Amplify.DataStore.query(T.self) { result in
            switch result {
            case .success(let juveniles):
                completion(juveniles)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func localFetchForJuvenileWithEventID(_ id: Int, completion: (Juvenile?) -> Void) {
        let p = Juvenile.keys
        Amplify.DataStore.query(Juvenile.self, where: p.event_id == id, completion: { result in
            switch result {
            case .success(let juveniles):
                if let juvenile = juveniles.first {
                    completion(juvenile)
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
