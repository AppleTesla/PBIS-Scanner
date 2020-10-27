// MARK: Imports

import SwiftUI
import Combine

// MARK: Views

struct ScanView: View {

    // MARK: Environment Objects

    @EnvironmentObject private var jvm: JuvenileManager

    @EnvironmentObject private var auth: AuthManager

    @EnvironmentObject private var blm: BehaviorLocationManager

    // MARK: Capture Session Properties

    @State private var showProfileDetail = false

    @State var sessionIsOffline = false

    @State var qrCodePublisher = PassthroughSubject<Int, Never>()

    var body: some View {
        ZStack(alignment: .top) {
            EmbeddedCaptureSessionViewController(sessionIsOffline: $sessionIsOffline,
                                                 qrPassthrough: $qrCodePublisher)
                .edgesIgnoringSafeArea(.all)
                .alert(isPresented: $sessionIsOffline) {
                    Alert(title: Text(.sessionAlertTitle),
                          message: Text(.sessionAlertMessage),
                          dismissButton: .default(Text(.sessionAlertDismiss)))
            }
                .onReceive(qrCodePublisher) { code in
                    self.jvm.fetchJuveniles(withEventID: code)
            }

            VStack {
                ZStack(alignment: .topLeading) {
                    LocationSelectorView()
                    ProfileIconView()
                        .padding([.top, .leading])
                        .onTapGesture {
                            self.showProfileDetail = true
                    }
                        .sheet(isPresented: $showProfileDetail) {
                            ProfileView(auth: self.auth, jvm: self.jvm)
                    }
                }

                Spacer()

                QueueDrawer { // Drawer expanded...
                    EmptyView()
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
