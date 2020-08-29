// MARK: Imports

import SwiftUI

// MARK: Views

struct ContentView: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isSignedIn {
                MainView()
            } else {
                SignInView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
