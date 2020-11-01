// MARK: Imports

import SwiftUI

// MARK: Views

struct ProfileView: View {

    // MARK: Environment Objects

    @ObservedObject var auth: AuthManager

    @ObservedObject var jvm: JuvenileManager

    @ObservedObject var blm: BehaviorLocationManager

    // MARK: View Properties

    @State var fullName = "Not Signed In"
    @State private var remainingPostsCount = 0

    @Environment(\.presentationMode) var presentationMode

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
                                .padding([.trailing, .vertical], 10)
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

                    Button {
                        self.jvm.bucketManagerDelegate?.attemptToPushPosts()
                    } label: {
                        HStack {
                            Text("Pending Upload")
                            Spacer()
                            Text("\(remainingPostsCount) juveniles")
                                .foregroundColor(.gray)
                        }
                    }
                    .disabled(!jvm.networkManager.isConnected || remainingPostsCount == 0)
                }

                Section {
                    Button("Upload History") { }
                        .disabled(true)
                    Button("Lock With Passcode") { }
                        .disabled(true)
                }

                Section {
                    Button("Report a bug") { }
                        .disabled(true)
                    Button("About") { }
                        .disabled(true)
                }

                Section(footer: Text(.copyright)) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.jvm.clearFromDataStore()
                        self.blm.clearFromDataStore()
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
        .onReceive(jvm.bucketManagerDelegate!.postRemainingCount) { count in
            remainingPostsCount = count
        }
        .onAppear {
            jvm.bucketManagerDelegate?.attemptToPushPosts()

            if let usernameData = self.auth.keychainManager.load(key: .username),
                let username = String(data: usernameData, encoding: .utf8) {
                self.fullName = username
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(auth: .init(), jvm: .init(), blm: .init())
    }
}
