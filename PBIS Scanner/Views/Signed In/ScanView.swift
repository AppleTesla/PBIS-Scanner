// MARK: Imports

import SwiftUI

// MARK: Views

struct ScanView: View {

    // MARK: Properties

    @EnvironmentObject private var apm: AppManager

    @EnvironmentObject private var jvm: JuvenileManager

    @State var sessionOffline = false

    var body: some View {
        VStack {
            EmbeddedCaptureSessionViewController(sessionOffline: $sessionOffline,
                                                 codeString: $apm.codeString)
                .alert(isPresented: $sessionOffline) {
                    Alert(title: Text(.hello),
                          message: Text(.hello),
                          dismissButton: .default(Text(.hello)))
            }
            .onReceive(apm.$codeString) { _ in
                guard let code = Int(self.apm.codeString) else { return }
                self.jvm.localFetch { (juveniles: [Juvenile]) in
                    if let juvenile = juveniles.first(where: { $0.event_id == code }), !self.jvm.juveniles.contains(juvenile) {
                        self.jvm.juveniles.append(juvenile)
                    } else {
                        self.jvm.remoteFetch { (juveniles: [Juvenile]) in
                            if let juvenile = juveniles.first(where: { $0.event_id == code }), !self.jvm.juveniles.contains(juvenile) {

                                print("no hit 1")

                                self.jvm.juveniles.append(juvenile)
                                if let currentKeychain = self.jvm.keychainManager.load(key: .queue),
                                    var array = try? JSONDecoder().decode([Int].self, from: currentKeychain) {

                                    print("no hit 2")

                                    if !array.contains(code) {
                                        array.append(code)
                                        if let newKeychain = try? JSONEncoder().encode(array) {
                                            _ = self.jvm.keychainManager.save(key: .queue, data: newKeychain)
                                        }
                                    }
                                } else {
                                    let array = [code]
                                    if let newKeychain = try? JSONEncoder().encode(array) {
                                        _ = self.jvm.keychainManager.save(key: .queue, data: newKeychain)
                                    }
                                }
                            }
                        }
                    }

                }
            }

            List {
                ForEach(jvm.juveniles, id: \.id) { juvenile in
                    Text(juvenile.first_name)
                }
            }
        }
        .onAppear {
            print("hit 1")
            guard let data = self.jvm.keychainManager.load(key: .queue),
                let array = try? JSONDecoder().decode([Int].self, from: data)
            else { return }

            print("hit 2", data)

            self.jvm.localFetch { (juveniles: [Juvenile]) in
                let filtered = juveniles.filter({ array.contains($0.event_id) })
                self.jvm.juveniles = filtered
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
