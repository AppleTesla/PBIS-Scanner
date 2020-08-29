// MARK: Imports

import Foundation

// MARK: Structs

struct EndpointConfiguration: GenericURLRequest {
    let path: Endpoint
    let httpMethod: HttpMethod
    var header: [String: String]?
    var query: [String: String]?
    var body: Data?

    init(path: Endpoint,
         httpMethod: HttpMethod,
         body: Data?,
         queryStrings: [String: String]?) {
        self.path = path
        self.httpMethod = httpMethod
        self.body = body
        query = queryStrings
    }
}
