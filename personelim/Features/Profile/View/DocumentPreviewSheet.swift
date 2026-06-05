import SwiftUI
import PDFKit

// MARK: - PDFKitView

struct PDFKitView: UIViewRepresentable {

    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .systemBackground
        view.document = document
        return view
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
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .task {
            await load()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingView
        } else if let pdfDocument {
            pdfView(pdfDocument)
        } else {
            errorView
        }
    }

    private func pdfView(_ document: PDFDocument) -> some View {
        VStack(spacing: 0) {
            previewHeader

            PDFKitView(document: document)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private var previewHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("PDF belge önizlemesi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                ProgressView()
            }
            .frame(width: 64, height: 64)

            VStack(spacing: 5) {
                Text("Belge yükleniyor")
                    .font(.headline)

                Text("PDF önizlemesi hazırlanıyor.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Error

    private var errorView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.10))

                Image(systemName: "doc.badge.exclamationmark")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.red)
            }
            .frame(width: 72, height: 72)

            VStack(spacing: 6) {
                Text("Belge açılamadı")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)

                Text(errorText ?? "Bilinmeyen hata")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text("Kapat")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.red.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Load

    private func load() async {
        isLoading = true
        errorText = nil
        pdfDocument = nil

        defer {
            isLoading = false
        }

        do {
            let data = try await network.downloadData(
                endpoint: .downloadDocument(documentId: documentId)
            )

            if data.count < 4 || String(data: data.prefix(4), encoding: .ascii) != "%PDF" {
                let sample = String(data: data.prefix(600), encoding: .utf8) ?? "binary/utf8 değil"

                throw NSError(
                    domain: "pdf",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "İndirilen içerik PDF değil.\nÖrnek yanıt:\n\(sample)"
                    ]
                )
            }

            guard let document = PDFDocument(data: data) else {
                throw NSError(
                    domain: "pdf",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey: "PDFDocument oluşturulamadı."
                    ]
                )
            }

            pdfDocument = document
        } catch {
            errorText = error.localizedDescription
        }
    }
}
