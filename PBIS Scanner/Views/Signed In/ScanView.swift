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
    
    @State private var showSubmitSheet = false

    @State var sessionIsOffline = false

    @State var qrCodePublisher = PassthroughSubject<Int, Never>()

    var body: some View {
        ZStack(alignment: .top) {
            EmbeddedCaptureSessionViewController(sessionIsOffline: $sessionIsOffline,
                                                 qrPassthrough: $qrCodePublisher)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: sessionIsOffline ? 30 : 0)
                .opacity(sessionIsOffline ? 0.5 : 1)
//                .alert(isPresented: $sessionIsOffline) {
//                    Alert(title: Text(.sessionAlertTitle),
//                          message: Text(.sessionAlertMessage),
//                          dismissButton: .default(Text(.sessionAlertDismiss)))
//                }
                .onReceive(qrCodePublisher) { code in
                    self.jvm.fetchJuveniles(withEventID: code)
                }
                .animation(.easeIn)

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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } else {
                            showSubmitSheet = true
                        }
                    }) {
                        Text(sessionIsOffline ? "Tap to Resume" : self.jvm.juveniles.isEmpty ? "Tap to Pause" : blm.selectedBehavior == nil ? "Select a location" : jvm.juveniles.isEmpty ? "Scanning..." : "Submit (\(jvm.juveniles.count))")
                            .fontWeight(.medium)
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(sessionIsOffline ? Color.red : blm.selectedBehavior == nil ? Color.gray : Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 5)
                    }
                    .padding(.horizontal)
                    .actionSheet(isPresented: $showSubmitSheet) {
                        ActionSheet(title: Text("Submit"), message: Text("Choose a behavior"), buttons: [
                            .default(Text("Safe")) {
                                blm.selectedCategory = .safe
                                self.jvm.saveToBucket(with: blm.selectedBehavior, for: jvm.juveniles)
                            },
                            .default(Text("Responsible")) {
                                blm.selectedCategory = .responsible
                                self.jvm.saveToBucket(with: blm.selectedBehavior, for: jvm.juveniles)
                            },
                            .default(Text("Considerate")) {
                                blm.selectedCategory = .considerate
                                self.jvm.saveToBucket(with: blm.selectedBehavior, for: jvm.juveniles)
                            },
                            .cancel()
                        ])
                    }
                    
                    if (!jvm.juveniles.isEmpty) {
                        JuvenileScrollView(juveniles: self.jvm.juveniles)
                    }
                }
                .animation(.easeOut)
            }
            .padding(.bottom)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
