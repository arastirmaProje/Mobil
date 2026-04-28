//
//  PerformanceReportDetailView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//


import SwiftUI
import Foundation

struct PerformanceReportDetailView: View {

    @Environment(\.dismiss) private var dismiss
    let reportId: String

    @StateObject private var vm: PerformanceReportDetailViewModel

    init(reportId: String) {
        self.reportId = reportId
        let repo = PerformanceRepositoryImpl(network: NetworkManager())
        let useCase = GetPerformanceReportDetailUseCase(repo: repo)
        _vm = StateObject(wrappedValue: PerformanceReportDetailViewModel(detailUseCase: useCase))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding()
                } else if let r = vm.report {
                    scoreHeader(r)

                    textCard(
                        title: ConstantStrings.summaryTitle,
                        text: (r.summaryText ?? "-").cleanedMarkdownAndRedactedIDs
                    )

                    textCard(
                        title: ConstantStrings.detailTitle,
                        text: (r.detailText ?? "-").cleanedMarkdownAndRedactedIDs
                    )
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .task { await vm.load(reportId: reportId) }
    }

    // MARK: - Score Header
    private func scoreHeader(_ r: PerformanceReportDTO) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: CGFloat(r.score ?? 0) / 100)
                    .stroke(
                        scoreColor(r.score ?? 0),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.2), value: r.score)

                VStack(spacing: 4) {
                    Text("\(r.score ?? 0)")
                        .font(.system(size: 44, weight: .bold))

                    Text(scoreLevel(r.score ?? 0))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(scoreColor(r.score ?? 0))
                }
            }
            .frame(width: 180, height: 180)

            Text(ConstantStrings.performanceScoreTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }

    // MARK: - Text Cards
    private func textCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            Text(text.isEmpty ? "-" : text)
                .font(.system(size: 14))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
        )
    }
}

// MARK: - Score Helpers (Aynı kalıyor)
private func scoreLevel(_ s: Int) -> String {
    switch s {
    case 0..<40: return ConstantStrings.levelPoor
    case 40..<70: return ConstantStrings.levelAverage
    case 70..<85: return ConstantStrings.levelGood
    default: return ConstantStrings.levelExcellent
    }
}

private func scoreColor(_ s: Int) -> Color {
    switch s {
    case 0..<40: return .red
    case 40..<70: return .orange
    case 70..<85: return .blue
    default: return .green
    }
}

// MARK: - Extensions (Aynı kalıyor)
private extension String {
    var cleanedMarkdownAndRedactedIDs: String {
        var s = self
        s = s.replacingOccurrences(of: "**", with: "")
        s = s.replacingOccurrences(of: "\n---\n", with: "\n")
        s = s.replacingOccurrences(of: "---", with: "")
        s = s.replacingOccurrences(of: "\n* ", with: "\n• ")
        s = s.replacingOccurrences(of: "\n* ", with: "\n• ")
        s = s.replacingOccurrences(of: "\n- ", with: "\n• ")
        s = s.removingLines(containingAnyOf: ["ID:", "Kimliği:", "Identifier:"])
        s = s.replacingUUIDs(with: "")
        s = s.replacingOccurrences(of: "  ", with: " ")
        while s.contains("\n\n\n") { s = s.replacingOccurrences(of: "\n\n\n", with: "\n\n") }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removingLines(containingAnyOf needles: [String]) -> String {
        let lines = self.components(separatedBy: .newlines)
        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return true }
            return !needles.contains(where: { trimmed.localizedCaseInsensitiveContains($0) })
        }
        return filtered.joined(separator: "\n")
    }

    private func replacingUUIDs(with replacement: String) -> String {
        let pattern = #"\b[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: replacement)
    }
}
