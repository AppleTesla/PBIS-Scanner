// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore

// MARK: Classes

final class AuthManager: ObservableObject, KeychainManagerInjector {

    // MARK: Initializers

    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }

        return window
    }

    // MARK: Published

    @Published var isSignedIn = false

    init() {
        checkSessionStatus()
        saveUserCredentials()
        observeAuthEvents()
    }

    private func checkSessionStatus() {
        let _ = Amplify.Auth.fetchAuthSession { [weak self] result in
            switch result {
            case .success(let session):
                DispatchQueue.main.async { self?.isSignedIn = session.isSignedIn }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: Listener

extension AuthManager {
    private func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth, listener: { [weak self] result in
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async { self?.isSignedIn = true }
            case HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.sessionExpired:
                DispatchQueue.main.async { self?.isSignedIn = false }
            default:
                break
            }
        })
    }
}

// MARK: Sign In

extension AuthManager {
    func webSignIn() {
        _ = Amplify.Auth.signInWithWebUI(presentationAnchor: window, listener: { result in
            switch result {
            case .success:
                print("User is signed in successfully.")
            case .failure(let error):
                print(error)
            }
        })
    }
}

// MARK: Sign Out

extension AuthManager {
    func signOut() {
        _ = Amplify.Auth.signOut(listener: { result in
            switch result {
            case .success:
                print("User has signed out successfully.")
            case .failure(let error):
                print(error)
            }
        })
    }
}

// MARK: CredentialsProvider

extension AuthManager: CredentialsProvider {
    func saveUserCredentials() {
        guard let user = Amplify.Auth.getCurrentUser(),
            let username = user.username.data(using: .utf8)
            else { return }

        let saveError = keychainManager.save(key: .username, data: username)

        if saveError != noErr {
            print(saveError)
            return
        }

        print("Successfully saved username to keychain.")
    }

    func getAccessToken(completion: @escaping (String?) -> Void) {
        Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()

                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()

                    guard let tokenData = tokens.idToken.data(using: .utf8) else {
                        print("Failed to retrieve id token and encode into data.")
                        return
                    }

                    let saveError = self.keychainManager.save(key: .token, data: tokenData)

                    if saveError != noErr {
                        print(saveError)
                        return
                    }

                    print("Successfully saved token to keychain!")
                    completion(tokens.idToken)
                }
            } catch {
                print(error)
            }
        }
    }
}

