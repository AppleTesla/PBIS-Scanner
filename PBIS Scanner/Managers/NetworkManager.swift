// MARK: Imports

import Foundation
import AVFoundation
import Network

// MARK: Classes

class NetworkManager: ObservableObject {
        
    // MARK: Published

    @Published var isConnected = true
    
    // MARK: Properties

    private let queue = DispatchQueue.global(qos: .background)
    
    private lazy var monitor: NWPathMonitor = {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        return monitor
    }()
        
    // MARK: Init

    init() {
        observeNetworkStatusEvents()
        monitor.start(queue: queue)
    }
    deinit {
        monitor.cancel()
    }
}

// MARK: Helper Methods

extension NetworkManager {
    func observeNetworkStatusEvents() {
        monitor.pathUpdateHandler = { path in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            if path.status == .satisfied {
                DispatchQueue.main.async { self.isConnected = true }
            } else {
                DispatchQueue.main.async { self.isConnected = false }
            }
        }
    }
}
