// MARK: Imports

import SwiftUI

// MARK: Views

struct ProfileView: View {

    // MARK: Environment Objects

    @EnvironmentObject private var auth: AuthManager

    @EnvironmentObject private var qm: QueueManager

    // MARK: View Properties

    @State var fullName = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(.personFill)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(fullName)
                                .font(.headline)
                            Text("Currently Online")
                                .font(.subheadline)
                        }
                    }
                }
                Section(footer: Text(.copyright)) {
                    Button(action: {
                        self.qm.clearAllData()
                        self.auth.signOut()
                    }) {
                        Text(.signOut)
                    }
                }
                .multilineTextAlignment(.center)
            }
            .navigationBarTitle(Text(.title))
        }
        .onAppear {
            if let usernameData = self.auth.keychainManager.load(key: .username),
                let username = String(data: usernameData, encoding: .utf8) {
                self.fullName = username
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
