// MARK: Imports

import Foundation

// MARK: Protocols

protocol GenericURLRequest {
    var path: Endpoint { get }
    var httpMethod: HttpMethod { get }
    var query: [String: String]? { get set }
    var header: [String: String]? { get set }
    var body: Data? { get set }
    init(path: Endpoint,
         httpMethod: HttpMethod,
         body: Data?,
         queryStrings: [String: String]?)
    func makeRequest(baseURL: BaseURL) -> URLRequest?
}
