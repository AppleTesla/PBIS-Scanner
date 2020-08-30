// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins

// MARK: Classes

class AppManager: ObservableObject {

    // MARK: Configuration

    @Published var tabIndex = 1
    @Published var codeString = ""

    // MARK: Plugins
    
    private let authPlugin = AWSCognitoAuthPlugin()
    private let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
    
    // MARK: Initializers
        
    init(completion: () -> Void) {
        configureAuth()
        configureDataStore()
        configureAmplify {
            completion()
        }
    }
    
    private func configureAuth() {
        do {
            try Amplify.add(plugin: authPlugin)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func configureDataStore() {
        do {
            try Amplify.add(plugin: dataStorePlugin)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func configureAmplify(completion: () -> Void) {
        do {
            try Amplify.configure()
            completion()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension AppManager {

}
