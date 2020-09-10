// MARK: Imports

import SwiftUI
import Combine

// MARK: Views

struct ScanView: View {

    // MARK: Environment Objects

    @EnvironmentObject private var jvm: JuvenileManager

    @EnvironmentObject private var blm: BehaviorLocationManager

    // MARK: Capture Session Properties

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
            .onReceive(qrCodePublisher
            .debounce(for: .milliseconds(ProcessInfo.processInfo.isLowPowerModeEnabled ? 25 : 10),
                      scheduler: RunLoop.main)) { code in
                        self.jvm.fetchJuveniles(withEventID: code) }

            VStack {
                LocationSelectorView()

                Spacer()

                QueueDrawer { // Drawer expanded...
                    EmptyView()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
