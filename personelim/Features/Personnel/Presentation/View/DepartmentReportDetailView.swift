import SwiftUI
import Foundation

struct DepartmentReportDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let reportId: String

    @StateObject private var vm = DepartmentReportDetailViewModel()
    @State private var animateIn = false

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
        }
        .task {
            await vm.load(reportId: reportId)

            withAnimation(.easeOut(duration: 0.45)) {
                animateIn = true
            }
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
                    .trim(from: 0, to: min(CGFloat(score) / 100, 1))
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

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.055), radius: 14, x: 0, y: 7)
    }
}

private func scoreLevel(_ score: Int) -> String {
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

private func scoreColor(_ score: Int) -> Color {
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
