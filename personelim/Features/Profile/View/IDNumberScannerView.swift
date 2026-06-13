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

    func updateUIViewController(
        _ uiViewController: ScannerHostViewController,
        context: Context
    ) { }

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
        private var didFinish = false

        private let topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        private let closeButton = UIButton(type: .system)
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        private let scanFrameView = UIView()
        private let scanLineView = UIView()
        private let hintContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        private let hintLabel = UILabel()

        private var scanLineTopConstraint: NSLayoutConstraint?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            setupOverlayUI()
            requestCameraPermissionAndStart()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            startIfNeeded()
            startScanLineAnimation()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            stopIfNeeded()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.bounds
        }

        private func requestCameraPermissionAndStart() {
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
                            self.onError?(ConstantStrings.cameraPermissionDenied)
                            self.onCancel?()
                        }
                    }
                }

            default:
                onError?(ConstantStrings.cameraPermissionDisabled)
                onCancel?()
            }
        }

        private func setupOverlayUI() {
            setupTopBar()
            setupScanFrame()
            setupHint()
        }

        private func setupTopBar() {
            topBlurView.translatesAutoresizingMaskIntoConstraints = false
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(topBlurView)

            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.tintColor = .white
            closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.14)
            closeButton.layer.cornerRadius = 18
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

            titleLabel.text = ConstantStrings.idScannerTitle
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)

            subtitleLabel.text = ConstantStrings.idScannerSubtitle
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.72)
            subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)

            topBlurView.contentView.addSubview(closeButton)
            topBlurView.contentView.addSubview(titleLabel)
            topBlurView.contentView.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                topBlurView.topAnchor.constraint(equalTo: view.topAnchor),
                topBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                topBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topBlurView.heightAnchor.constraint(equalToConstant: 112),

                closeButton.leadingAnchor.constraint(equalTo: topBlurView.leadingAnchor, constant: 16),
                closeButton.bottomAnchor.constraint(equalTo: topBlurView.bottomAnchor, constant: -16),
                closeButton.widthAnchor.constraint(equalToConstant: 36),
                closeButton.heightAnchor.constraint(equalToConstant: 36),

                titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: topBlurView.trailingAnchor, constant: -16),
                titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -2),

                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: topBlurView.bottomAnchor, constant: -15)
            ])
        }

        private func setupScanFrame() {
            scanFrameView.translatesAutoresizingMaskIntoConstraints = false
            scanLineView.translatesAutoresizingMaskIntoConstraints = false

            scanFrameView.layer.cornerRadius = 26
            scanFrameView.layer.borderWidth = 2
            scanFrameView.layer.borderColor = UIColor.white.withAlphaComponent(0.92).cgColor
            scanFrameView.backgroundColor = .clear

            scanLineView.backgroundColor = .systemBlue
            scanLineView.layer.cornerRadius = 2
            scanLineView.layer.shadowColor = UIColor.systemBlue.cgColor
            scanLineView.layer.shadowOpacity = 0.8
            scanLineView.layer.shadowRadius = 10
            scanLineView.layer.shadowOffset = .zero

            view.addSubview(scanFrameView)
            scanFrameView.addSubview(scanLineView)

            scanLineTopConstraint = scanLineView.topAnchor.constraint(
                equalTo: scanFrameView.topAnchor,
                constant: 18
            )

            NSLayoutConstraint.activate([
                scanFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                scanFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
                scanFrameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82),
                scanFrameView.heightAnchor.constraint(equalToConstant: 220),

                scanLineView.leadingAnchor.constraint(equalTo: scanFrameView.leadingAnchor, constant: 18),
                scanLineView.trailingAnchor.constraint(equalTo: scanFrameView.trailingAnchor, constant: -18),
                scanLineView.heightAnchor.constraint(equalToConstant: 4),
                scanLineTopConstraint!
            ])

            addCornerGuides()
        }

        private func addCornerGuides() {
            let guideLength: CGFloat = 34
            let guideWidth: CGFloat = 4

            let positions: [(CGFloat, CGFloat, CGFloat)] = [
                (0, 0, 0),
                (1, 0, 90),
                (1, 1, 180),
                (0, 1, 270)
            ]

            positions.forEach { x, y, rotation in
                let corner = UIView()
                corner.translatesAutoresizingMaskIntoConstraints = false
                corner.backgroundColor = .clear

                let horizontal = UIView()
                let vertical = UIView()

                horizontal.translatesAutoresizingMaskIntoConstraints = false
                vertical.translatesAutoresizingMaskIntoConstraints = false

                horizontal.backgroundColor = .systemBlue
                vertical.backgroundColor = .systemBlue

                horizontal.layer.cornerRadius = guideWidth / 2
                vertical.layer.cornerRadius = guideWidth / 2

                corner.addSubview(horizontal)
                corner.addSubview(vertical)
                scanFrameView.addSubview(corner)

                NSLayoutConstraint.activate([
                    corner.widthAnchor.constraint(equalToConstant: guideLength),
                    corner.heightAnchor.constraint(equalToConstant: guideLength),

                    horizontal.leadingAnchor.constraint(equalTo: corner.leadingAnchor),
                    horizontal.topAnchor.constraint(equalTo: corner.topAnchor),
                    horizontal.widthAnchor.constraint(equalToConstant: guideLength),
                    horizontal.heightAnchor.constraint(equalToConstant: guideWidth),

                    vertical.leadingAnchor.constraint(equalTo: corner.leadingAnchor),
                    vertical.topAnchor.constraint(equalTo: corner.topAnchor),
                    vertical.widthAnchor.constraint(equalToConstant: guideWidth),
                    vertical.heightAnchor.constraint(equalToConstant: guideLength)
                ])

                if x == 0 {
                    corner.leadingAnchor.constraint(equalTo: scanFrameView.leadingAnchor, constant: -1).isActive = true
                } else {
                    corner.trailingAnchor.constraint(equalTo: scanFrameView.trailingAnchor, constant: 1).isActive = true
                }

                if y == 0 {
                    corner.topAnchor.constraint(equalTo: scanFrameView.topAnchor, constant: -1).isActive = true
                } else {
                    corner.bottomAnchor.constraint(equalTo: scanFrameView.bottomAnchor, constant: 1).isActive = true
                }

                corner.transform = CGAffineTransform(rotationAngle: rotation * .pi / 180)
            }
        }

        private func setupHint() {
            hintContainer.translatesAutoresizingMaskIntoConstraints = false
            hintLabel.translatesAutoresizingMaskIntoConstraints = false

            hintContainer.layer.cornerRadius = 18
            hintContainer.layer.masksToBounds = true

            hintLabel.text = ConstantStrings.idScannerHint
            hintLabel.textColor = .white
            hintLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            hintLabel.numberOfLines = 2
            hintLabel.textAlignment = .center

            view.addSubview(hintContainer)
            hintContainer.contentView.addSubview(hintLabel)

            NSLayoutConstraint.activate([
                hintContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                hintContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                hintContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
                hintContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),

                hintLabel.leadingAnchor.constraint(equalTo: hintContainer.contentView.leadingAnchor, constant: 14),
                hintLabel.trailingAnchor.constraint(equalTo: hintContainer.contentView.trailingAnchor, constant: -14),
                hintLabel.topAnchor.constraint(equalTo: hintContainer.contentView.topAnchor, constant: 10),
                hintLabel.bottomAnchor.constraint(equalTo: hintContainer.contentView.bottomAnchor, constant: -10)
            ])
        }

        private func startScanLineAnimation() {
            view.layoutIfNeeded()

            scanLineTopConstraint?.constant = 18
            view.layoutIfNeeded()

            UIView.animate(
                withDuration: 1.35,
                delay: 0,
                options: [.autoreverse, .repeat, .curveEaseInOut],
                animations: { [weak self] in
                    guard let self else { return }
                    self.scanLineTopConstraint?.constant = 198
                    self.view.layoutIfNeeded()
                }
            )
        }

        @objc private func closeTapped() {
            finishWithCancel()
        }

        private func setupPreferredScanner() {
            if DataScannerViewController.isSupported &&
                DataScannerViewController.isAvailable {
                setupDataScanner()
            } else {
                setupOCRFallback()
            }
        }

        private func setupDataScanner() {
            let viewController = DataScannerViewController(
                recognizedDataTypes: [.text()],
                qualityLevel: .accurate,
                recognizesMultipleItems: true,
                isHighFrameRateTrackingEnabled: true,
                isGuidanceEnabled: true,
                isHighlightingEnabled: true
            )

            viewController.delegate = self
            scanner = viewController

            addChild(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(viewController.view, at: 0)

            NSLayoutConstraint.activate([
                viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            viewController.didMove(toParent: self)
        }

        private func startIfNeeded() {
            if let scanner {
                if !scanner.isScanning {
                    do {
                        try scanner.startScanning()
                    } catch {
                        onError?(ConstantStrings.visionKitFallbackMessage)
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

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didTapOn item: RecognizedItem
        ) {
            scanRecognizedItems([item])
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            scanRecognizedItems(addedItems)
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didUpdate updatedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            scanRecognizedItems(updatedItems)
        }

        private func scanRecognizedItems(_ items: [RecognizedItem]) {
            guard !didFinish else { return }

            let combinedText = items.compactMap { item -> String? in
                guard case .text(let text) = item else { return nil }
                return text.transcript
            }
            .joined(separator: " ")

            guard let tc = Self.extract11Digits(from: combinedText) else {
                return
            }

            finishWithTC(tc)
        }

        func dataScannerDidCancel(_ dataScanner: DataScannerViewController) {
            finishWithCancel()
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didFailWithError error: Error
        ) {
            onError?(ConstantStrings.visionKitErrorFallbackMessage)
            teardownDataScanner()
            setupOCRFallback()
            startOCRIfNeeded()
        }

        private func teardownDataScanner() {
            if let scanner {
                if scanner.isScanning {
                    scanner.stopScanning()
                }

                scanner.willMove(toParent: nil)
                scanner.view.removeFromSuperview()
                scanner.removeFromParent()
                self.scanner = nil
            }
        }

        private func setupOCRFallback() {
            guard !isUsingOCR else { return }

            isUsingOCR = true

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high

            guard
                let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ),
                let input = try? AVCaptureDeviceInput(device: device),
                captureSession.canAddInput(input)
            else {
                onError?(ConstantStrings.cameraStartFailed)
                onCancel?()
                captureSession.commitConfiguration()
                return
            }

            captureSession.addInput(input)

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String:
                    kCVPixelFormatType_32BGRA
            ]
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)

            guard captureSession.canAddOutput(videoOutput) else {
                onError?(ConstantStrings.cameraOutputFailed)
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

        private func finishWithTC(_ tc: String) {
            guard !didFinish else { return }

            didFinish = true
            stopIfNeeded()

            DispatchQueue.main.async { [weak self] in
                self?.onFound?(tc)
            }
        }

        private func finishWithCancel() {
            guard !didFinish else { return }

            didFinish = true
            stopIfNeeded()
            onCancel?()
        }

        static func extract11Digits(from string: String) -> String? {
            let normalized = string
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\t", with: "")

            let pattern = #"(?<!\d)\d{11}(?!\d)"#

            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                return nil
            }

            let range = NSRange(
                normalized.startIndex..<normalized.endIndex,
                in: normalized
            )

            let matches = regex.matches(
                in: normalized,
                range: range
            )

            for match in matches {
                guard let swiftRange = Range(match.range, in: normalized) else {
                    continue
                }

                let candidate = String(normalized[swiftRange])

                if isValidTurkishID(candidate) {
                    return candidate
                }
            }

            return nil
        }

        static func isValidTurkishID(_ value: String) -> Bool {
            guard value.count == 11,
                  value.allSatisfy(\.isNumber),
                  value.first != "0" else {
                return false
            }

            let digits = value.compactMap { Int(String($0)) }

            guard digits.count == 11 else {
                return false
            }

            let oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
            let evenSum = digits[1] + digits[3] + digits[5] + digits[7]

            let tenthDigit = ((oddSum * 7) - evenSum) % 10
            let eleventhDigit = digits[0...9].reduce(0, +) % 10

            return digits[9] == tenthDigit && digits[10] == eleventhDigit
        }
    }
}

extension IDNumberScannerView.ScannerHostViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = CACurrentMediaTime()

        if now - lastHitAt < 0.25 { return }
        if isProcessingFrame { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        isProcessingFrame = true

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self else { return }

            defer {
                self.isProcessingFrame = false
            }

            if error != nil {
                DispatchQueue.main.async {
                    self.onError?(ConstantStrings.ocrReadFailed)
                }
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let text = observations
                .compactMap { $0.topCandidates(3).first?.string }
                .joined(separator: " ")

            if let tc = Self.extract11Digits(from: text) {
                self.lastHitAt = CACurrentMediaTime()

                DispatchQueue.main.async {
                    self.finishWithTC(tc)
                }
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.01
        request.recognitionLanguages = ["tr-TR", "en-US"]

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right,
            options: [:]
        )

        do {
            try handler.perform([request])
        } catch {
            isProcessingFrame = false

            DispatchQueue.main.async { [weak self] in
                self?.onError?(ConstantStrings.ocrStartFailed)
            }
        }
    }
}
