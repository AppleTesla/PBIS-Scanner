// MARK: Imports

import SwiftUI

// MARK: Views

struct AppView: View {
    
    // MARK: Properties

    @EnvironmentObject private var qm: QueueManager

    @EnvironmentObject private var amp: AmplifyConfigurator

    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Group {
            if auth.isSignedIn {
                TabView(selection: $amp.tabIndex) {
                    HistoryView()
                        .tabItem {
                            amp.tabIndex == 0 ? Image(.personFill) : Image(.person)
                    }
                    .tag(0)
                    ScanView()
                        .tabItem {
                            amp.tabIndex == 1 ? Image(.barcode) : Image(.viewfinder)
                    }
                    .tag(1)
                    ProfileView()
                        .tabItem {
                            amp.tabIndex == 2 ? Image(.clockFill) : Image(.clock)
                    }
                    .tag(2)
                }
            } else {
                SignInView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
