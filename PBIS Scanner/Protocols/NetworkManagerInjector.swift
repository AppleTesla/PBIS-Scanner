// MARK: Imports

import Foundation

// MARK: Protocols

fileprivate let sharedNetworkManager = NetworkManager()

protocol NetworkManagerInjector {
    var networkManager: NetworkManager { get }
}

extension NetworkManagerInjector {
    var networkManager: NetworkManager {
        return sharedNetworkManager
    }
}
