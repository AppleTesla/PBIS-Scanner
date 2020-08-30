// MARK: Imports

import AVFoundation
import SwiftUI

// MARK: UIVIewControllerRepresentable

struct EmbeddedCaptureSessionViewController: UIViewControllerRepresentable {

    @Binding var sessionOffline: Bool
    @Binding var codeString: String

    func makeCoordinator() -> CaptureSessionCoordinator {
        CaptureSessionCoordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CaptureSessionViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class CaptureSessionCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate, CaptureSessionSetupDelegate {

    var sessionFailed: Bool = false {
        didSet {
            parent.sessionOffline = sessionFailed
        }
    }

    var parent: EmbeddedCaptureSessionViewController

    init(_ viewController: EmbeddedCaptureSessionViewController) {
        self.parent = viewController
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            parent.codeString = stringValue
        }
    }
}

// MARK: UIVIewController

class CaptureSessionViewController: UIViewController {

    weak var delegate: CaptureSessionCoordinator?

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetadataOutput()
        lockFocus()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = view.bounds

        switch UIDevice.current.orientation {
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeLeft
        default:
            previewLayer.connection?.videoOrientation = .portrait
        }
    }
}

// MARK: Capture Session Setup

extension CaptureSessionViewController: CaptureSessionSetup {
    func setupMetadataOutput() {
        captureSession = AVCaptureSession()
        captureDevice = AVCaptureDevice.default(for: .video)

        guard let captureDevice = captureDevice else { return }
        let videoInput: AVCaptureDeviceInput

        do { videoInput = try AVCaptureDeviceInput(device: captureDevice) }
        catch { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.sessionFailed = true
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128]
        } else {
            delegate?.sessionFailed = true
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else { return }
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func lockFocus() {
        do { try captureDevice?.lockForConfiguration() }
        catch { print(error) }

        captureDevice?.setFocusModeLocked(lensPosition: 0.1, completionHandler: nil)
    }
}
