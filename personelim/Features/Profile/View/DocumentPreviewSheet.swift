import SwiftUI
import PDFKit

// MARK: - PDFKitView (UIViewRepresentable)
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        v.document = document
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

// MARK: - DocumentPreviewSheet
struct DocumentPreviewSheet: View {
    let title: String
    let documentId: String
    let network: NetworkManager

    @Environment(\.dismiss) private var dismiss

    @State private var isLoading = true
    @State private var pdfDocument: PDFDocument?
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Yükleniyor…")
                        .padding()
                } else if let pdfDocument {
                    PDFKitView(document: pdfDocument)
                        .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    VStack(spacing: 12) {
                        Text("Belge açılamadı")
                            .font(.headline)

                        Text(errorText ?? "Bilinmeyen hata")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)

                        Button("Kapat") { dismiss() }
                    }
                    .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorText = nil
        pdfDocument = nil
        defer { isLoading = false }

        do {
            let data = try await network.downloadData(endpoint: .downloadDocument(documentId: documentId))
            if data.count < 4 || String(data: data.prefix(4), encoding: .ascii) != "%PDF" {
                let sample = String(data: data.prefix(600), encoding: .utf8) ?? "binary/utf8 değil"
                throw NSError(
                    domain: "pdf",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "İndirilen içerik PDF değil.\nÖrnek yanıt:\n\(sample)"]
                )
            }

            guard let doc = PDFDocument(data: data) else {
                throw NSError(
                    domain: "pdf",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "PDFDocument oluşturulamadı."]
                )
            }

            pdfDocument = doc
        } catch {
            errorText = error.localizedDescription
        }
    }
}
