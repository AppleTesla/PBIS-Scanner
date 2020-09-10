// MARK: Imports

import SwiftUI

// MARK: Views

struct ProfileView: View {

    // MARK: Environment Objects

    @EnvironmentObject private var auth: AuthManager

    @EnvironmentObject private var jvm: JuvenileManager

    // MARK: View Properties

    @State var fullName = "Not Signed In"

    @State var connectionState = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: ProfileDetailView(km: auth.keychainManager)
                        .navigationBarTitle(Text(fullName), displayMode: .inline)) {
                        HStack {
                            ProfileIconView(badges: [])
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 50)
                                .padding(10)
                            VStack(alignment: .leading) {
                                Text(fullName)
                                    .font(.headline)
                                Text(connectionState)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .onReceive(jvm.apiManager.networkManager.$isConnected) { state in
                                        self.connectionState = localized(state ? LocalizationKey.connected.rawValue : LocalizationKey.disconnected.rawValue)
                                }
                            }
                        }
                    }
                }

                Section(footer: Text(.copyright)) {
                    Button(action: {
                        self.jvm.apiManager.clearAllData()
                        self.auth.signOut()
                    }) {
                        Text(.signOut)
                            .foregroundColor(.red)
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
