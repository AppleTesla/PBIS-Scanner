// MARK: Imports

import SwiftUI

// MARK: Views

struct SignInView: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Button(action: {
            self.authManager.webSignIn()
        }, label: {
            Text("Sign In")
        })
            .padding()
            .background(Color.purple)
            .cornerRadius(5)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
