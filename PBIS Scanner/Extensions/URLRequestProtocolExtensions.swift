// MARK: Imports

import Foundation

// MARK: Extensions

extension GenericURLRequest {
    func makeRequest(baseURL: BaseURL) -> URLRequest? {
        var urlcomponent = URLComponents()
        urlcomponent.host = baseURL.rawValue
        urlcomponent.path = path.endpoint
        urlcomponent.scheme = "https"
        urlcomponent.queryItems = query?.reduce([]) { (result, element) -> [URLQueryItem] in
            let (key, value) = element
            let queryItem = URLQueryItem(name: key, value: value)
            return result + [queryItem]
        }
        guard let url = urlcomponent.url else { return nil }
        var request = URLRequest(url: url)
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = header
        return request
    }
}
