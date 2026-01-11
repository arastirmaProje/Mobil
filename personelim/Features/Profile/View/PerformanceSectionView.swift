import SwiftUI

struct PerformanceSectionView: View {

    let reports: [PerformanceReportDTO]
    let isLoading: Bool
    let error: String?

    let onCreateQuery: () -> Void
    let onSelectReport: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Sorgu")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button(action: onCreateQuery) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Sorgu")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)


            if isLoading {
                ProgressView().padding(.top, 8)
            }

            if reports.isEmpty && !isLoading {
                emptyReportCard
            } else {
                VStack(spacing: 10) {
                    ForEach(reports) { r in
                        PerformanceReportCard(report: r) {
                            onSelectReport(r.id)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var emptyReportCard: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemGray6))
            .frame(height: 70)
            .overlay(
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Henüz rapor yok")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Tarih aralığı seçip sorgu oluştur.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, 12)
            )
    }
}

// MARK: - Performance Report Card (DETAIL İLE BİREBİR)

private struct PerformanceReportCard: View {
    let report: PerformanceReportDTO
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                .frame(height: 82)
                .overlay(
                    HStack(spacing: 14) {

                        ScoreMiniGauge(score: report.score ?? 0)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sorgu Aralığı")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)

                            Text(ISODate.shortRange(start: report.startDate, end: report.endDate))
                                .font(.system(size: 13, weight: .semibold))

                            Text(scoreLevel(report.score ?? 0))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(scoreColor(report.score ?? 0))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 14)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini Radial Gauge (DETAIL İLE BİREBİR)

private struct ScoreMiniGauge: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 6)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    scoreColor(score),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(score)")
                .font(.system(size: 12, weight: .bold))
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Score Helpers

private func scoreLevel(_ s: Int) -> String {
    switch s {
    case 0..<40: return "Zayıf"
    case 40..<70: return "Orta"
    case 70..<85: return "İyi"
    default: return "Mükemmel"
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
