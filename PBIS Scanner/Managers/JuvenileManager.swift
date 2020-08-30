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
    private func remoteFetchForAll<T: Model>(_ object: T, completion: @escaping ([T]) -> Void) {
        var endpointConfig: EndpointConfiguration!

        switch object {
        case is Juvenile:
            endpointConfig = juvenilesEndpointConfig
// TODO: Add new model types
//        case is Behavior:
//            endpointConfig = behaviorsEndpointConfig
//        case is Location:
//            endpointConfig = locationsEndpointConfig
//        case is Reward:
//            endpointConfig = rewardsEndpointConfig
        default:
            print("Could not configure endpoint.")
            return
        }

        apiManager.fetch(from: endpointConfig) { (result: Result<[T], ResponseError>) in
            switch result {
            case .success(let objects):
                completion(objects)
            case .failure(let error):
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
    
    func localFetchForAll<T: Model>(completion: ([T]) -> Void) {
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
