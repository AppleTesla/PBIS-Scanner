// MARK: Imports

import SwiftUI

// MARK: Views

struct SignInView: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Image("collab")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 100, alignment: .center)
            Text("PBIS Scan")
                .fontWeight(.bold)
                .font(.largeTitle)
            Text("Strengthening the youth through positive reinforcement")
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Button(action: {
                self.authManager.signInWithWebUI()
            }, label: {
                HStack {
                    Text("Sign In or Sign Up")
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    if authManager.showProgress {
                        Spacer().frame(width: 10)
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    }
                }
            })
                .padding()
                .background(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(5)
        }
        .padding(.top)
        .padding(.bottom, 75)
        .background(Image("bg"))
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
