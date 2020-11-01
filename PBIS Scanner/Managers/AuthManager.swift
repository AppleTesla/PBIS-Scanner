// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore
import Combine

// MARK: Classes

final class AuthManager: ObservableObject, KeychainManagerInjector {

    // MARK: Initializers

    private var initCancellable: AnyCancellable?
    private var stateCancellable: AnyCancellable?
    private var tokenCancellable: AnyCancellable?

    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
            else { return UIWindow() }

        return window
    }

    // MARK: Published

    @Published var isSignedIn = true
    @Published var showProgress = false

    init() {
        initCancellable = checkSessionStatus()
        stateCancellable = observeAuthEvents()
        tokenCancellable = fetchTokens()
    }

    deinit {
        initCancellable?.cancel()
        stateCancellable?.cancel()
    }

    private func checkSessionStatus() -> AnyCancellable {
        Amplify.Auth.fetchAuthSession().resultPublisher
            .sink(receiveCompletion: {
            if case let .failure(authError) = $0 {
                print("Fetch session failed with error \(authError)")
            }
        },
        receiveValue: { session in
            self.isSignedIn = session.isSignedIn
        })
    }
}

// MARK: Listener

extension AuthManager {
    private func observeAuthEvents() -> AnyCancellable {
        Amplify.Hub
            .publisher(for: .auth)
            .sink { payload in
                switch payload.eventName {
                case HubPayload.EventName.Auth.signedIn:
                    DispatchQueue.main.async { self.isSignedIn = true }
                case HubPayload.EventName.Auth.signedOut,
                     HubPayload.EventName.Auth.sessionExpired:
                    DispatchQueue.main.async { self.isSignedIn = false }
                default:
                    break
                }
        }
    }
}

// MARK: Sign In

extension AuthManager {
    func signInWithWebUI() {
        showProgress = true
        Amplify.Auth.signInWithWebUI(presentationAnchor: window) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                DispatchQueue.main.async { self.showProgress = false }
            case .failure(let error):
                print("Sign in failed \(error)")
                DispatchQueue.main.async { self.showProgress = false }
            }
        }
    }
}

// MARK: Sign Out

extension AuthManager {
    func signOut(completion: @escaping (Bool) -> Void) {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
                completion(true)
            case .failure(let error):
                print("Sign out failed with error \(error)")
                completion(false)
            }
        }
    }
}

// MARK: Provide vars for CredentialsProvider

extension AuthManager: CredentialsProvider {
    public func fetchTokens() -> AnyCancellable {
        Amplify.Auth.fetchAuthSession()
            .resultPublisher
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    print("Failed to fetch credentials: \(error)")
                }
            },
            receiveValue: {session in
                if let session = session as? AuthCognitoTokensProvider {
                    do {
                        let tokens = try session.getCognitoTokens().get()
                        let saveError = self.keychainManager.save(key: .token, data: tokens.idToken.data(using: .utf8)!)
                        if saveError != noErr { print(saveError) }

                        let json = try JSONUtility().decode(jwtToken: tokens.idToken)
                        if let username = json["name"] as? String,
                           let email = json["email"] as? String,
                           let verification = json["email_verified"] as? Int  {
                            _ = self.keychainManager.save(key: .username, data: username.data(using: .utf8)!)
                            _ = self.keychainManager.save(key: .email, data: email.data(using: .utf8)!)
                            let isVerifiedData = try JSONEncoder().encode(verification == 1)
                            _ = self.keychainManager.save(key: .isVerified, data: isVerifiedData)
                        }
                    } catch {
                        print("TokenError", error)
                        self.signOut { _ in }
                    }
                }
        })
    }
}
