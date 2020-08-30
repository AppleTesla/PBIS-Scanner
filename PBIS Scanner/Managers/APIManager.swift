// MARK: Imports

import Foundation
import Network

// MARK: Classes

class APIManager: APIManagerProtocol, NetworkManagerInjector, KeychainManagerInjector {

    var baseURL: BaseURL = .prod
    var session: URLSession = URLSession.shared
    var decoder: JSONDecoder = JSONDecoder()

    func fetch<T: Decodable>(from api: EndpointConfiguration,
                             dataTaskQueue: DispatchQueue = DispatchQueue.global(),
                             resultQueue: DispatchQueue = .main,
                             completion: @escaping (Result<T, ResponseError>) -> Void) {
        guard networkManager.isConnected else {
            completion(.failure(.networkProblem))
            return
        }

        guard
            let tokenData = keychainManager.load(key: .token),
            let token = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(.tokenProblem))
            return
        }

        guard var request = api.makeRequest(baseURL: baseURL) else {
            completion(.failure(.requestProblem))
            return
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization.rawValue)

        let dataTask = session.dataTask(with: request) { data, response, error in
            var result: Result<T, ResponseError> = .failure(.deferred)

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

            print(response.description)
            print(String(data: data, encoding: .utf8) ?? "Data is nil")
            return
        }

        dataTaskQueue.async { dataTask.resume() }
    }
}

