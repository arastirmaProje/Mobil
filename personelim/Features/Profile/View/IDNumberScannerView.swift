import SwiftUI
import VisionKit
import AVFoundation
import Vision

struct IDNumberScannerView: UIViewControllerRepresentable {

    let onFound: (String) -> Void
    let onCancel: () -> Void
    let onError: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerHostViewController {
        let host = ScannerHostViewController()
        host.onFound = onFound
        host.onCancel = onCancel
        host.onError = onError
        return host
    }

    func updateUIViewController(_ uiViewController: ScannerHostViewController, context: Context) {}

    // MARK: - Host VC (DataScanner -> fallback OCR)
    final class ScannerHostViewController: UIViewController, DataScannerViewControllerDelegate {

        var onFound: ((String) -> Void)?
        var onCancel: (() -> Void)?
        var onError: ((String) -> Void)?

        private var scanner: DataScannerViewController?

        private let captureSession = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer?
        private let videoOutput = AVCaptureVideoDataOutput()
        private let captureQueue = DispatchQueue(label: "ocr.capture.queue")
        private var isUsingOCR = false

        private var isProcessingFrame = false
        private var lastHitAt: CFTimeInterval = 0

        private let closeButton = UIButton(type: .system)
        private let hintLabel = UILabel()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black

            setupOverlayUI()

            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                setupPreferredScanner()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        if granted {
                            self.setupPreferredScanner()
                        } else {
                            self.onError?("Kamera izni verilmedi.")
                            self.onCancel?()
                        }
                    }
                }
            default:
                onError?("Kamera izni kapalı. Ayarlar > Gizlilik > Kamera'dan aç.")
                onCancel?()
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            startIfNeeded()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            stopIfNeeded()
        }

        // MARK: - UI
        private func setupOverlayUI() {
            closeButton.setTitle("Kapat", for: .normal)
            closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

            hintLabel.text = "Kimliği kameraya göster. 11 haneli TC otomatik bulunur."
            hintLabel.textColor = .white
            hintLabel.font = .systemFont(ofSize: 13, weight: .medium)
            hintLabel.numberOfLines = 2
            hintLabel.textAlignment = .center
            hintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            hintLabel.layer.cornerRadius = 10
            hintLabel.layer.masksToBounds = true

            closeButton.translatesAutoresizingMaskIntoConstraints = false
            hintLabel.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(closeButton)
            view.addSubview(hintLabel)

            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

                hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hintLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
                hintLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.92),
                hintLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
        }

        @objc private func closeTapped() {
            onCancel?()
        }

        // MARK: - Preferred scanner selection
        private func setupPreferredScanner() {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                setupDataScanner()
            } else {
                setupOCRFallback()
            }
        }

        private func setupDataScanner() {
            let vc = DataScannerViewController(
                recognizedDataTypes: [.text()],
                qualityLevel: .balanced,
                recognizesMultipleItems: false,
                isHighFrameRateTrackingEnabled: false,
                isGuidanceEnabled: true,
                isHighlightingEnabled: true
            )
            vc.delegate = self
            self.scanner = vc

            addChild(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(vc.view, at: 0)
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            vc.didMove(toParent: self)
        }

        // MARK: - Start/Stop
        private func startIfNeeded() {
            if let scanner {
                if !scanner.isScanning {
                    do {
                        try scanner.startScanning()
                    } catch {
                        onError?("VisionKit tarama başlatılamadı, OCR moduna geçiliyor.")
                        teardownDataScanner()
                        setupOCRFallback()
                        startOCRIfNeeded()
                    }
                }
            } else if isUsingOCR {
                startOCRIfNeeded()
            }
        }

        private func stopIfNeeded() {
            if let scanner, scanner.isScanning {
                scanner.stopScanning()
            }
            stopOCRIfNeeded()
        }

        // MARK: - DataScanner Delegate
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            guard case .text(let text) = item else { return }
            let raw = text.transcript
            if let tc = Self.extract11Digits(from: raw) {
                onFound?(tc)
            }
        }

        func dataScannerDidCancel(_ dataScanner: DataScannerViewController) {
            onCancel?()
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didFailWithError error: Error) {
            onError?("VisionKit hata verdi, OCR moduna geçiliyor.")
            teardownDataScanner()
            setupOCRFallback()
            startOCRIfNeeded()
        }

        private func teardownDataScanner() {
            if let scanner {
                if scanner.isScanning { scanner.stopScanning() }
                scanner.willMove(toParent: nil)
                scanner.view.removeFromSuperview()
                scanner.removeFromParent()
                self.scanner = nil
            }
        }

        // MARK: - OCR Fallback (AVCapture + Vision)
        private func setupOCRFallback() {
            guard !isUsingOCR else { return }
            isUsingOCR = true

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                captureSession.canAddInput(input)
            else {
                onError?("Kamera başlatılamadı.")
                onCancel?()
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(input)

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)

            guard captureSession.canAddOutput(videoOutput) else {
                onError?("Kamera çıktısı eklenemedi.")
                onCancel?()
                captureSession.commitConfiguration()
                return
            }
            captureSession.addOutput(videoOutput)

            if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
            }

            captureSession.commitConfiguration()

            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            previewLayer = layer
        }

        private func startOCRIfNeeded() {
            guard isUsingOCR else { return }
            if !captureSession.isRunning {
                captureQueue.async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
        }

        private func stopOCRIfNeeded() {
            guard isUsingOCR else { return }
            if captureSession.isRunning {
                captureQueue.async { [weak self] in
                    self?.captureSession.stopRunning()
                }
            }
        }


        static func extract11Digits(from s: String) -> String? {
            let digits = s.filter(\.isNumber)
            guard digits.count >= 11 else { return nil }
            let tc = String(digits.prefix(11))
            return tc.count == 11 ? tc : nil
        }
    }
}

extension IDNumberScannerView.ScannerHostViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let now = CACurrentMediaTime()
        if now - lastHitAt < 0.20 { return }
        if isProcessingFrame { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessingFrame = true
        defer { isProcessingFrame = false }

        let request = VNRecognizeTextRequest { [weak self] req, err in
            guard let self else { return }

            if let err {
                DispatchQueue.main.async {
                    self.onError?("OCR hata: \(err.localizedDescription)")
                }
                return
            }

            guard let observations = req.results as? [VNRecognizedTextObservation] else { return }
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")

            if let tc = Self.extract11Digits(from: text) {
                self.lastHitAt = CACurrentMediaTime()

                DispatchQueue.main.async {
                    self.stopOCRIfNeeded()
                    self.onFound?(tc)
                }
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.02
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.onError?("OCR başlatılamadı: \(error.localizedDescription)")
            }
        }
    }
}
