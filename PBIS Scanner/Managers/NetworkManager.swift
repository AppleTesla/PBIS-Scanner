// MARK: Imports

import Foundation
import AVFoundation
import Network

// MARK: Classes

final class NetworkManager: ObservableObject {
        
    // MARK: Published

    @Published var isConnected = true
    
    // MARK: Properties

    private let queue = DispatchQueue.global(qos: .background)
    
    private var monitor: NWPathMonitor?
        
    // MARK: Init

    init() {
        connect()
    }

    deinit {
        disconnect()
    }
}

// MARK: Helper Methods

extension NetworkManager {
    func connect() {
        monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        observeNetworkStatusEvents()
        monitor?.start(queue: queue)
    }

    func disconnect() {
        monitor?.cancel()
        monitor = nil
    }

    func observeNetworkStatusEvents() {
        monitor?.pathUpdateHandler = { path in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            if path.status == .satisfied {
                DispatchQueue.main.async { self.isConnected = true }
            } else {
                DispatchQueue.main.async { self.isConnected = false }
            }
        }
    }
}
