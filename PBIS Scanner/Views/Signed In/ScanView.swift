// MARK: Imports

import SwiftUI
import Combine

// MARK: Views

struct ScanView: View {

    // MARK: Environment Objects

    @EnvironmentObject private var qm: QueueManager

    // MARK: View Properties

    @State var sessionIsOffline = false

    @State var qrCodePublisher = PassthroughSubject<Int, Never>()

    var body: some View {
        VStack {
            EmbeddedCaptureSessionViewController(sessionIsOffline: $sessionIsOffline,
                                                 qrPassthrough: $qrCodePublisher)
                .alert(isPresented: $sessionIsOffline) {
                    Alert(title: Text(.sessionAlertTitle),
                          message: Text(.sessionAlertMessage),
                          dismissButton: .default(Text(.sessionAlertDismiss)))
            }
            .onReceive(qrCodePublisher
            .debounce(for: .milliseconds(ProcessInfo.processInfo.isLowPowerModeEnabled ? 50 : 25),
                      scheduler: DispatchQueue.main)) { code in
                        self.qm.fetchJuvenilesWithOfflinePriority(withEventID: code)
            }
            .edgesIgnoringSafeArea(.all)

            List {
                ForEach(qm.juveniles) { juvenile in
                    Text(juvenile.first_name)
                }
                .onDelete(perform: self.qm.removeJuveniles)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
