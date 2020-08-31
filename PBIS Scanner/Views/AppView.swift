// MARK: Imports

import SwiftUI

// MARK: Views

struct AppView: View {
    
    // MARK: Properties

    @EnvironmentObject private var qm: QueueManager

    @EnvironmentObject private var amp: AmplifyConfigurator

    @EnvironmentObject private var auth: AuthManager

    // MARK: View Properties

    private enum Tabs: Int { case first, second }
    @State private var tabIndex: Tabs = .first

    var body: some View {
        Group {
            if auth.isSignedIn {
                TabView(selection: $tabIndex) {
                    ScanView()
                        .tabItem {
                            tabIndex == .first ? Image(.barcode) : Image(.viewfinder)
                    }
                    .tag(Tabs.first)
                    
                    ProfileView()
                        .tabItem {
                            tabIndex == .second ? Image(.personFill) : Image(.person)
                    }
                    .tag(Tabs.second)
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
