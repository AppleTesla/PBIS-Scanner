// MARK: Imports

import Foundation

// MARK: Protocols

protocol APIManagerProtocol {
    var baseURL: BaseURL { get }
    var session: URLSession { get }
    func fetch<T: Decodable>(from api: EndpointConfiguration,
                             dataTaskQueue: DispatchQueue,
                             resultQueue: DispatchQueue,
                             completion: @escaping (Result<T, ResponseError>) -> Void)
}
