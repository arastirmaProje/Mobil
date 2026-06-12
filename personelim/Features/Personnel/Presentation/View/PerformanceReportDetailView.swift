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
    @State private var animateIn = false

    init(reportId: String) {
        self.reportId = reportId

        let repo = PerformanceRepositoryImpl(network: NetworkManager())
        let useCase = GetPerformanceReportDetailUseCase(repo: repo)

        _vm = StateObject(
            wrappedValue: PerformanceReportDetailViewModel(
                detailUseCase: useCase
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    if vm.isLoading {
                        loadingView
                    } else if let err = vm.errorMessage {
                        errorView(err)
                    } else if let r = vm.report {
                        scoreHeader(r)

                        textCard(
                            icon: "text.alignleft",
                            title: ConstantStrings.summaryTitle,
                            text: (r.summaryText ?? ConstantStrings.dashPlaceholder)
                                .cleanedMarkdownAndRedactedIDs
                        )

                        textCard(
                            icon: "doc.text.magnifyingglass",
                            title: ConstantStrings.detailTitle,
                            text: (r.detailText ?? ConstantStrings.dashPlaceholder)
                                .cleanedMarkdownAndRedactedIDs
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
        .navigationTitle(ConstantStrings.performanceReportTitle)
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
        }
        .task {
            await vm.load(reportId: reportId)

            withAnimation(.easeOut(duration: 0.45)) {
                animateIn = true
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.1)

            Text(ConstantStrings.reportLoading)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 38))
                .foregroundStyle(.orange)

            Text(ConstantStrings.reportLoadFailed)
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

    // MARK: - Score Header

    private func scoreHeader(_ r: PerformanceReportDTO) -> some View {
        let score = r.score ?? 0

        return VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(ConstantStrings.performanceScoreTitle)
                        .font(.title3.weight(.bold))

                    Text(scoreLevel(score))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(scoreColor(score))
                }

                Spacer()

                Text(String(format: ConstantStrings.performanceScoreFormat, score))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(scoreColor(score))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(scoreColor(score).opacity(0.14))
                    )
            }

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.14), lineWidth: 18)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        scoreColor(score),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.1), value: score)

                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text(scoreLevel(score))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(scoreColor(score))
                }
            }
            .frame(width: 178, height: 178)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(cardBackground(cornerRadius: 26))
    }

    // MARK: - Text Cards

    private func textCard(
        icon: String,
        title: String,
        text: String
    ) -> some View {
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

    // MARK: - Shared Card Background

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.055), radius: 14, x: 0, y: 7)
    }
}

// MARK: - Score Helpers

private func scoreLevel(_ s: Int) -> String {
    switch s {
    case 0..<40:
        return ConstantStrings.levelPoor

    case 40..<70:
        return ConstantStrings.levelAverage

    case 70..<85:
        return ConstantStrings.levelGood

    default:
        return ConstantStrings.levelExcellent
    }
}

private func scoreColor(_ s: Int) -> Color {
    switch s {
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

    var cleanedMarkdownAndRedactedIDs: String {
        var s = self

        s = s.replacingOccurrences(of: "**", with: "")
        s = s.replacingOccurrences(of: "\n---\n", with: "\n")
        s = s.replacingOccurrences(of: "---", with: "")
        s = s.replacingOccurrences(of: "\n* ", with: "\n• ")
        s = s.replacingOccurrences(of: "\n- ", with: "\n• ")
        s = s.removingLines(containingAnyOf: ["ID:", "Kimliği:", "Identifier:"])
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
