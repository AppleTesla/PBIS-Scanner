// MARK: Imports

import Foundation

// MARK: Protocols

protocol CaptureSessionSetupDelegate {
    var sessionFailed : Bool { get set }
}

protocol CaptureSessionSetup {
    func setupMetadataOutput()
    func lockFocus()
}
