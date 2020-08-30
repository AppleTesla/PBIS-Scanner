// MARK: Imports

import Foundation

// MARK: Protocols

fileprivate let sharedAuthManager = AuthManager()

protocol AuthManagerInjector {
    var authManager: AuthManager { get }
}

extension AuthManagerInjector {
    var authManager: AuthManager {
        return sharedAuthManager
    }
}
