import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}

struct DocumentPreviewSheet: View {
    let title: String
    let documentId: String
    let network: NetworkManager

    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var localURL: URL?
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Yükleniyor…")
                } else if let url = localURL {
                    PDFKitView(url: url)
                        .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    VStack(spacing: 12) {
                        Text(errorText ?? "Belge açılamadı.")
                            .foregroundColor(.red)
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
        localURL = nil

        do {
            let data = try await network.downloadData(endpoint: .downloadDocument(documentId: documentId))
            localURL = try FileStore.writeTempPDF(data: data, fileName: title)
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }
}
