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
//                .alert(isPresented: $sessionIsOffline) {
//                    Alert(title: Text(.sessionAlertTitle),
//                          message: Text(.sessionAlertMessage),
//                          dismissButton: .default(Text(.sessionAlertDismiss)))
//                }
                .onReceive(qrCodePublisher) { code in
                    self.jvm.fetchJuveniles(withEventID: code)
                }

            VStack {
                ZStack(alignment: .topLeading) {
                    LocationSelectorView()
                    Button {
                        self.showProfileDetail = true
                    } label: {
                        ProfileIconView()
                            .padding([.top, .leading])
                    }
                    .sheet(isPresented: $showProfileDetail) {
                        ProfileView(auth: self.auth, jvm: self.jvm, blm: self.blm)
                    }
                }

                Spacer()
                
                VStack {
                    Button(action: {
                        if (jvm.juveniles.isEmpty) {
                            sessionIsOffline.toggle()
                        } else {
                            self.jvm.saveToBucket(with: self.blm.selectedBehavior, for: self.jvm.juveniles)
                        }
                    }) {
                        Text(sessionIsOffline ? "Paused" : self.jvm.juveniles.isEmpty ? "Tap to Pause" : blm.selectedBehavior == nil ? "Select a location" : jvm.juveniles.isEmpty ? "Scanning..." : "Submit (\(jvm.juveniles.count))")
                            .fontWeight(.medium)
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(blm.selectedBehavior == nil ? Color.gray : Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 5)
//                            .disabled(blm.selectedBehavior == nil)
                    }
                    .padding(.horizontal)
                    if (!jvm.juveniles.isEmpty) {
                        JuvenileScrollView(juveniles: self.jvm.juveniles)
                    }
                }
                .animation(.easeOut)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
