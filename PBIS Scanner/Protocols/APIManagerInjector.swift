// MARK: Imports

import Foundation

// MARK: Protocols

fileprivate let sharedAPIManager = APIManager()

protocol APIManagerInjector {
    var apiManager: APIManager { get }
}

extension APIManagerInjector {
    var apiManager: APIManager {
        return sharedAPIManager
    }
}
