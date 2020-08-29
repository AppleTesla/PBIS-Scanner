// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins

// MARK: Classes

class AuthManager: ObservableObject {
    
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

// MARK: Listener

extension AuthManager {
    func observeAuthEvents() {
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
