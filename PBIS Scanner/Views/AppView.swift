// MARK: Imports

import SwiftUI

// MARK: Views

struct AppView: View {
    
    // MARK: Properties

    @EnvironmentObject private var jvm: JuvenileManager

    @EnvironmentObject private var amp: AmplifyConfigurator

    @EnvironmentObject private var auth: AuthManager

    @EnvironmentObject private var uim: UIManager

    enum Tabs: Int { case first, second }
    @State var tabIndex: Tabs = .first

    var body: some View {
        Group {
            if auth.isSignedIn {
                ScanView()
            } else {
                SignInView()
            }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(named: "TabBar_Color")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
