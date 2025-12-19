//
//  IDNumberScannerView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 18.12.2025.
//

import SwiftUI
import VisionKit

struct IDNumberScannerView: UIViewControllerRepresentable {

    let onFound: (String) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFound: onFound, onCancel: onCancel)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onFound: (String) -> Void
        let onCancel: () -> Void

        init(onFound: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
            self.onFound = onFound
            self.onCancel = onCancel
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            guard case .text(let text) = item else { return }
            let raw = text.transcript
            if let tc = Self.extract11Digits(from: raw) {
                onFound(tc)
            }
        }

        func dataScannerDidCancel(_ dataScanner: DataScannerViewController) {
            onCancel()
        }

        static func extract11Digits(from s: String) -> String? {
            let digits = s.filter(\.isNumber)
            guard digits.count >= 11 else { return nil }

            let tc = String(digits.prefix(11))
            return tc.count == 11 ? tc : nil
        }
    }
}

extension IDNumberScannerView {
    static func start(_ vc: DataScannerViewController) {
        try? vc.startScanning()
    }
}
