// MARK: Imports

import Foundation

// MARK: Protocols

fileprivate let sharedKeychainManager = KeychainManager()

protocol KeychainManagerInjector {
    var keychainManager: KeychainManager { get }
}

extension KeychainManagerInjector {
    var keychainManager: KeychainManager {
        return sharedKeychainManager
    }
}
