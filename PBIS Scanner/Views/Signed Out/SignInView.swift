// MARK: Imports

import SwiftUI

// MARK: Views

struct SignInView: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Button(action: {
            self.authManager.signInWithWebUI()
        }, label: {
            Text("Please Sign In")
        })
            .padding()
            .background(Color.white)
            .cornerRadius(5)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
