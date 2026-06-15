import SwiftUI
import Foundation
import UIKit

struct DepartmentReportDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let reportId: String

    @StateObject private var vm = DepartmentReportDetailViewModel()
    @State private var animateIn = false
    @State private var pdfShareItem: DepartmentPDFShareItem?
    @State private var isExportingPDF = false
    @State private var pdfErrorMessage: String?

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    if vm.isLoading {
                        loadingView
                    } else if let error = vm.errorMessage {
                        errorView(error)
                    } else if let report = vm.report {
                        scoreHeader(report)

                        textCard(
                            icon: "text.alignleft",
                            title: ConstantStrings.reportSummaryTitle,
                            text: report.raporOzeti.cleanedDepartmentReportText
                        )

                        textCard(
                            icon: "doc.text.magnifyingglass",
                            title: ConstantStrings.detailedReportTitle,
                            text: report.detayliRapor.cleanedDepartmentReportText
                        )
                    }

                    Spacer().frame(height: 36)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 14)
            }
        }
        .navigationTitle(ConstantStrings.departmentReportDetailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    exportPDF()
                } label: {
                    if isExportingPDF {
                        ProgressView()
                            .scaleEffect(0.85)
                            .frame(width: 34, height: 34)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(vm.report == nil || isExportingPDF)
            }
        }
        .task {
            await vm.load(reportId: reportId)

            withAnimation(.easeOut(duration: 0.45)) {
                animateIn = true
            }
        }
        .sheet(item: $pdfShareItem) { item in
            DepartmentActivityView(activityItems: [item.url])
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding(
                get: { pdfErrorMessage != nil },
                set: { if !$0 { pdfErrorMessage = nil } }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(pdfErrorMessage ?? "")
        }
    }

    private func exportPDF() {
        guard let report = vm.report else { return }

        isExportingPDF = true
        pdfErrorMessage = nil

        Task { @MainActor in
            do {
                let url = try DepartmentReportPDFExporter.export(report: report)
                pdfShareItem = DepartmentPDFShareItem(url: url)
            } catch {
                pdfErrorMessage = ConstantStrings.pdfCreateFailed
            }

            isExportingPDF = false
        }
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.1)

            Text(ConstantStrings.departmentReportLoading)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 38))
                .foregroundStyle(.orange)

            Text(ConstantStrings.departmentReportLoadFailed)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(cardBackground(cornerRadius: 22))
    }

    private func scoreHeader(_ report: DepartmentPerformanceResponseDTO) -> some View {
        let score = Int(report.departmanSkoru.rounded())

        return VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(ConstantStrings.departmentScoreTitle)
                        .font(.title3.weight(.bold))

                    Text(departmentScoreLevel(score))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(departmentScoreColor(score))
                }

                Spacer()

                Text(String(format: ConstantStrings.performanceScoreFormat, score))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(departmentScoreColor(score))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(departmentScoreColor(score).opacity(0.14))
                    )
            }

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.14), lineWidth: 18)

                Circle()
                    .trim(from: 0, to: min(CGFloat(score) / 100, 1))
                    .stroke(
                        departmentScoreColor(score),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.1), value: score)

                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text(departmentScoreLevel(score))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(departmentScoreColor(score))
                }
            }
            .frame(width: 178, height: 178)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(cardBackground(cornerRadius: 26))
    }

    private func textCard(icon: String, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                    )

                Text(title)
                    .font(.headline.weight(.semibold))

                Spacer()
            }

            Text(text.isEmpty ? ConstantStrings.dashPlaceholder : text)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground(cornerRadius: 22))
    }

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.055), radius: 14, x: 0, y: 7)
    }
}

// MARK: - PDF Exporter

private enum DepartmentReportPDFExporter {

    static func export(report: DepartmentPerformanceResponseDTO) throws -> URL {
        let fileName = "\(ConstantStrings.departmentReportPDFFilePrefix)-\(UUID().uuidString).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 42
        let contentWidth = pageWidth - (margin * 2)

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            var y: CGFloat = margin

            func attributes(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 4
                paragraph.paragraphSpacing = 6

                return [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
            }

            func textHeight(_ text: String, font: UIFont) -> CGFloat {
                let rect = NSString(string: text).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes(font: font, color: .black),
                    context: nil
                )

                return ceil(rect.height)
            }

            func newPageIfNeeded(_ neededHeight: CGFloat) {
                if y > margin && y + neededHeight > pageHeight - margin {
                    context.beginPage()
                    y = margin
                }
            }

            func drawText(
                _ text: String,
                font: UIFont,
                color: UIColor = .black,
                spacing: CGFloat = 10
            ) {
                let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !clean.isEmpty else { return }

                let height = textHeight(clean, font: font)
                newPageIfNeeded(height)

                NSString(string: clean).draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes(font: font, color: color),
                    context: nil
                )

                y += height + spacing
            }

            func drawLongText(
                _ text: String,
                font: UIFont,
                color: UIColor = .black,
                spacing: CGFloat = 8
            ) {
                let paragraphs = text
                    .components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                for paragraph in paragraphs {
                    guard !paragraph.isEmpty else {
                        y += 6
                        continue
                    }

                    let paragraphHeight = textHeight(paragraph, font: font)
                    let availableHeight = pageHeight - margin - y

                    if paragraphHeight <= availableHeight {
                        drawText(paragraph, font: font, color: color, spacing: spacing)
                    } else {
                        drawParagraphByWords(
                            paragraph,
                            font: font,
                            color: color,
                            spacing: spacing
                        )
                    }
                }
            }

            func drawParagraphByWords(
                _ paragraph: String,
                font: UIFont,
                color: UIColor,
                spacing: CGFloat
            ) {
                let words = paragraph.split(separator: " ").map(String.init)
                var current = ""

                for word in words {
                    let candidate = current.isEmpty ? word : "\(current) \(word)"
                    let candidateHeight = textHeight(candidate, font: font)
                    let availableHeight = pageHeight - margin - y

                    if candidateHeight > availableHeight {
                        if !current.isEmpty {
                            drawText(current, font: font, color: color, spacing: spacing)
                            current = word
                        } else {
                            context.beginPage()
                            y = margin
                            current = word
                        }
                    } else {
                        current = candidate
                    }
                }

                if !current.isEmpty {
                    drawText(current, font: font, color: color, spacing: spacing)
                }
            }

            let score = Int(report.departmanSkoru.rounded())
            let summary = report.raporOzeti.cleanedDepartmentReportText
            let detail = report.detayliRapor.cleanedDepartmentReportText

            drawText(
                ConstantStrings.departmentReportPDFTitle,
                font: .boldSystemFont(ofSize: 24),
                spacing: 16
            )

            drawText(
                "\(ConstantStrings.departmentScoreTitle): \(score)",
                font: .boldSystemFont(ofSize: 17),
                color: UIColor(departmentScoreColor(score)),
                spacing: 6
            )

            drawText(
                "\(ConstantStrings.performanceReportPDFLevel): \(departmentScoreLevel(score))",
                font: .systemFont(ofSize: 14),
                color: .darkGray,
                spacing: 14
            )

            drawText(
                ConstantStrings.reportSummaryTitle,
                font: .boldSystemFont(ofSize: 18),
                spacing: 8
            )

            drawLongText(
                summary,
                font: .systemFont(ofSize: 13),
                spacing: 10
            )

            drawText(
                ConstantStrings.detailedReportTitle,
                font: .boldSystemFont(ofSize: 18),
                spacing: 8
            )

            drawLongText(
                detail,
                font: .systemFont(ofSize: 13),
                spacing: 8
            )
        }

        return url
    }
}

// MARK: - Share Sheet

private struct DepartmentPDFShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

private struct DepartmentActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}

// MARK: - Score Helpers

private func departmentScoreLevel(_ score: Int) -> String {
    switch score {
    case 0..<40:
        return ConstantStrings.departmentPerformanceWeakStatus
    case 40..<70:
        return ConstantStrings.departmentPerformanceMediumStatus
    case 70..<85:
        return ConstantStrings.departmentPerformanceGoodStatus
    default:
        return ConstantStrings.departmentPerformanceExcellentStatus
    }
}

private func departmentScoreColor(_ score: Int) -> Color {
    switch score {
    case 0..<40:
        return .red
    case 40..<70:
        return .orange
    case 70..<85:
        return .blue
    default:
        return .green
    }
}

// MARK: - Extensions

private extension String {

    var cleanedDepartmentReportText: String {
        var value = self

        value = value.replacingOccurrences(of: "**", with: "")
        value = value.replacingOccurrences(of: "\n---\n", with: "\n")
        value = value.replacingOccurrences(of: "---", with: "")
        value = value.replacingOccurrences(of: "\n* ", with: "\n• ")
        value = value.replacingOccurrences(of: "\n- ", with: "\n• ")
        value = value.removingLines(containingAnyOf: ["ID:", "Kimliği:", "Identifier:"])
        value = value.replacingUUIDs(with: "")
        value = value.replacingOccurrences(of: "  ", with: " ")

        while value.contains("\n\n\n") {
            value = value.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removingLines(containingAnyOf needles: [String]) -> String {
        let lines = self.components(separatedBy: .newlines)

        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmed.isEmpty else {
                return true
            }

            return !needles.contains {
                trimmed.localizedCaseInsensitiveContains($0)
            }
        }

        return filtered.joined(separator: "\n")
    }

    private func replacingUUIDs(with replacement: String) -> String {
        let pattern = #"\b[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}\b"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return self
        }

        let range = NSRange(self.startIndex..<self.endIndex, in: self)

        return regex.stringByReplacingMatches(
            in: self,
            range: range,
            withTemplate: replacement
        )
    }
}
