// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class AmplifyConfigurator: ObservableObject {

    // MARK: Navigation

    @Published var tabIndex = 1

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
            print(error.localizedDescription)
        }
    }
    
    private func configureDataStore() {
        do {
            try Amplify.add(plugin: dataStorePlugin)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func configureAmplify(completion: () -> Void) {
        do {
            try Amplify.configure()
            completion()
        } catch {
            print(error.localizedDescription)
        }
    }
}
