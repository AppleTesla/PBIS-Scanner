// MARK: Imports

import Foundation
import Network
import Amplify
import Combine

// MARK: Classes

final class APIManager: APIManagerProtocol, NetworkManagerInjector, KeychainManagerInjector {

    // MARK: Credentials

    var credentialsDelegate: CredentialsProvider?

    // MARK: Default Endpoints

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

    // MARK: URLRequestProtocol

    var baseURL: BaseURL = .prod
    var session: URLSession = URLSession.shared
    var decoder: JSONDecoder = JSONDecoder()

    /// This method should not be used outside of APIManager.
    func request<T: Decodable>(from api: EndpointConfiguration,
                             dataTaskQueue: DispatchQueue = DispatchQueue.global(),
                             resultQueue: DispatchQueue = .main,
                             completion: @escaping (Result<T, ResponseError>) -> Void) {

        guard let token_RAW = keychainManager.load(key: .token),
            let token = String(data: token_RAW, encoding: .utf8) else {
            completion(.failure(.tokenProblem))
            return
        }

        guard networkManager.isConnected else {
            completion(.failure(.networkProblem))
            return
        }

        guard var request = api.makeRequest(baseURL: baseURL) else {
            completion(.failure(.requestProblem))
            return
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization.rawValue)

        let dataTask = session.dataTask(with: request) { data, response, error in
            var result: Result<T, ResponseError> = .failure(.deferred)

//            print(response)

            defer { resultQueue.async { completion(result) } }

            if let error = error {
                result = .failure(.responseProblem(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                result = .failure(.responseProblem(URLError(.badServerResponse)))
                return
            }

            if response.statusCode == 401 {
                result = .failure(.otherProblem(URLError(.userAuthenticationRequired)))
                return
            }

            guard let data = data else {
                result = .failure(.decodingProblem(URLError(.cannotDecodeRawData)))
                return
            }

            if let model = try? self.decoder.decode(T.self, from: data) {
                result = .success(model)
                return
            }

            return
        }

        dataTaskQueue.async { dataTask.resume() }
    }
}

// MARK: Saving & Deleting

extension APIManager {
    /// This is a wrapper for Ampllify DataStore's save method. If it detects an already-present entity, it updates its attributes.
    func save<T: Model>(entity: T, completion: ((Bool) -> ())? = nil) {
        Amplify.DataStore.save(entity) { result in
            switch result {
            case .success(let object):
//                print("\(object.modelName) successfully saved to disk.")
                completion?(true)
            case .failure(let error):
                print(error)
                completion?(false)
            }
        }
    }

    /// This is a wrapper for Ampllify DataStore's delete method.
    func delete<T: Model>(entity: T, completion: ((Bool) -> ())? = nil) {
        Amplify.DataStore.delete(entity) { result in
            switch result {
            case .success:
                print("Successfully deleted \(entity.modelName) from disk.")
                completion?(true)
            case .failure(let error):
                print(error)
                completion?(false)
            }
        }
    }
}

// MARK: Flush

extension APIManager {
    /// This is a wrapper for Ampllify DataStore's clear method. Use this upon signing out of the app.
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

// MARK: Local Fetch

extension APIManager {
    /// This is a wrapper for Ampllify DataStore's query method. Returns an array of the specified model type.
    func offlineFetch<T: Model>(predicate: QueryPredicate? = nil, sort: QuerySortInput? = nil, completion: ([T]) -> Void) {
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

// MARK: Remote Fetch

extension APIManager {
    /// Use this remote fetch function if the object return type is expected to be an atomic array and there are no special parameters. Location is likely to be the only endpoint in need of this treatment.
    func fetchOnlineAtomic<T: Model, U: Decodable>(_ model: T.Type, withType atomic: U.Type, customEndpoint: EndpointConfiguration? = nil, completion: @escaping ([U]) -> Void) {
        var endpointConfig: EndpointConfiguration! = customEndpoint

        switch T.self {
        case is Location.Type:
            endpointConfig = locationsEndpointConfig
        default:
            print("Could not configure endpoint for type \(model.modelName).")
            return
        }

        request(from: endpointConfig) { (result: Result<[U], ResponseError>) in
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
    func fetchOnlineObject<T: Model>(customEndpoint: EndpointConfiguration? = nil, completion: @escaping (T?) -> Void) {
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

        request(from: endpointConfig) { (result: Result<T?, ResponseError>) in
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
    func fetchOnlineList<T: Model>(completion: @escaping ([T]) -> Void) {
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

        request(from: endpointConfig) { (result: Result<[T], ResponseError>) in
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
