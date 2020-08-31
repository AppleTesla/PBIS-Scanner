// MARK: Imports

import SwiftUI
import Combine

// MARK: Views

struct ScanView: View {

    // MARK: Properties

    @EnvironmentObject private var apm: AppManager

    @EnvironmentObject private var qm: QueueManager

    @State var sessionIsOffline = false

    @State var qrCodePublisher = PassthroughSubject<Int, Never>()

    var body: some View {
        VStack {
            EmbeddedCaptureSessionViewController(sessionIsOffline: $sessionIsOffline,
                                                 qrPassthrough: $qrCodePublisher)
                .alert(isPresented: $sessionIsOffline) {
                    Alert(title: Text(.hello),
                          message: Text(.hello),
                          dismissButton: .default(Text(.hello)))
            }
            .onReceive(qrCodePublisher.debounce(for: .milliseconds(ProcessInfo.processInfo.isLowPowerModeEnabled ? 50 : 25),
                                                scheduler: DispatchQueue.main)) { code in
                                                    self.qm.blendFetchJuvenile(withEventID: code)
            }

            List {
                ForEach(qm.juveniles, id: \.id) { juvenile in
                    Text(juvenile.first_name)
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
