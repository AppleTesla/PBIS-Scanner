// MARK: Imports

import SwiftUI

// MARK: Views

struct ProfileDetailView: View {

    let km: KeychainManager

    @State var attributeDictionary = Dictionary<String, String>()

    var body: some View {
        List {
            ForEach(attributeDictionary.keys.sorted(), id: \.self) { key in
                ListRowView(key: Text(key), value: Text(String(self.attributeDictionary[key]!)))
            }
        }
        .onAppear {
            let usernameKey = KeychainCategory.username
            let emailKey = KeychainCategory.email
            let verificationKey = KeychainCategory.isVerified

            if let username_RAW = self.km.load(key: usernameKey),
                let username = String(data: username_RAW, encoding: .utf8) {
                self.attributeDictionary[usernameKey.rawValue] = username
            }

            if let email_RAW = self.km.load(key: emailKey),
                let email = String(data: email_RAW, encoding: .utf8) {
                self.attributeDictionary[emailKey.rawValue] = email
            }

            if let verified_RAW = self.km.load(key: verificationKey),
                let isVerifiedBool = try? JSONDecoder().decode(Bool.self, from: verified_RAW) {
                self.attributeDictionary[verificationKey.rawValue] = isVerifiedBool ? "Yes" : "No"
            }
        }
    }
}
