// MARK: Imports

import UIKit
import SwiftUI

// MARK: Classes

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // MARK: Managers
    
    var appManager: AppManager?
    var authManager: AuthManager?
    var queueManager: QueueManager?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Initialize all managers used direcly by SwiftUI views.

        appManager = AppManager {
            authManager = AuthManager()
            queueManager = QueueManager()
        }

        guard let appManager = appManager,
            let authManager = authManager,
            let queueManager = queueManager
            else { return }

        // Configure any delegates for communication between managers.

        queueManager.apiManager.credentialsDelegate = authManager

        // Create the SwiftUI view that provides the window contents.

        let contentView = AppView()
            .environmentObject(appManager)
            .environmentObject(authManager)
            .environmentObject(queueManager)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Rebuild Keychain items
        authManager?.getAccessToken { token in
            guard let token = token,
                let data = token.data(using: .utf8)
                else { return }
            _ = self.queueManager?.apiManager.keychainManager.save(key: .token, data: data)
        }

        // Restart network manager
        queueManager?.apiManager.networkManager.connect()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Release Keychain items
        queueManager?.apiManager.keychainManager.remove(key: .token)

        // Restart network manager
        queueManager?.apiManager.networkManager.disconnect()
        
    }
}

