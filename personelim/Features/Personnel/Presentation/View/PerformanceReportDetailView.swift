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
        VStack(spacing: 0) {

            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Sorgu Detay")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.top, 6)

                    if vm.isLoading {
                        ProgressView().padding(.top, 12)
                    }

                    if let err = vm.errorMessage {
                        Text(err).foregroundColor(.red)
                    }

                    if let r = vm.report {
                        donutRow(r)

                    
                        textCard(
                            title: "Özet",
                            text: (r.summaryText ?? "-").cleanedMarkdownAndRedactedIDs
                        )

        
                        textCard(
                            title: "Detay",
                            text: (r.detailText ?? "-").cleanedMarkdownAndRedactedIDs
                        )
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .navigationBarHidden(true)
        .task { await vm.load(reportId: reportId) }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private func donutRow(_ r: PerformanceReportDTO) -> some View {
        HStack(alignment: .center, spacing: 14) {

            ScoreDonut(score: r.score ?? 0)
                .frame(width: 110, height: 110)

            VStack(alignment: .leading, spacing: 6) {
                Text(r.createdByName ?? "— tarafından")
                    .font(.system(size: 13, weight: .semibold))

                Text(ISODate.shortRange(start: r.startDate, end: r.endDate))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.top, 6)
    }

    private func textCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            Text(text.isEmpty ? "-" : text)
                .font(.system(size: 13))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

private struct ScoreDonut: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(UIColor.systemGray5), lineWidth: 14)

            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(100, score))) / 100.0)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(score)")
                .font(.system(size: 22, weight: .semibold))
        }
    }
}

// MARK: - Markdown Cleaner + ID Redaction

private extension String {

    var cleanedMarkdownAndRedactedIDs: String {
        var s = self

        s = s.replacingOccurrences(of: "**", with: "")
        s = s.replacingOccurrences(of: "\n---\n", with: "\n")
        s = s.replacingOccurrences(of: "---", with: "")

        s = s.replacingOccurrences(of: "\n*   ", with: "\n• ")
        s = s.replacingOccurrences(of: "\n* ", with: "\n• ")
        s = s.replacingOccurrences(of: "\n- ", with: "\n• ")

        s = s.removingLines(containingAnyOf: [
            "Çalışan ID:",
            "Çalışan Kimliği:",
            "Employee ID:",
            "Employee Identifier:"
        ])

        s = s.replacingUUIDs(with: "")

        s = s.replacingOccurrences(of: "  ", with: " ")
        while s.contains("\n\n\n") {
            s = s.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removingLines(containingAnyOf needles: [String]) -> String {
        let lines = self.components(separatedBy: .newlines)
        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false else { return true }
            return needles.contains(where: { trimmed.localizedCaseInsensitiveContains($0) }) == false
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
