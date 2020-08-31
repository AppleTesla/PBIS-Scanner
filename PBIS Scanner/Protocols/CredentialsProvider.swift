// MARK: Imports

import Foundation

// MARK: Protocols

protocol CredentialsProvider: class {
    func saveUserCredentials()
    func getAccessToken(completion: @escaping (String?) -> Void)
}
