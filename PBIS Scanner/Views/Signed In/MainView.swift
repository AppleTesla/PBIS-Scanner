// MARK: Imports

import SwiftUI

// MARK: Views

struct ContentView: View {
    
    // MARK: Properties

    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Button(action: {
            self.authManager.signOut()
        }, label: {
            Text("Sign Out")
        })
            .padding()
            .background(Color.purple)
            .cornerRadius(5)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
