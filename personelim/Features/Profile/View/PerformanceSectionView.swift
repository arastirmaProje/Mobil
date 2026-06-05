import SwiftUI

struct PerformanceSectionView: View {

    let reports: [PerformanceReportDTO]
    let isLoading: Bool
    let error: String?

    let onCreateQuery: () -> Void
    let onSelectReport: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            header

            if let error {
                errorRow(error)
            }

            if isLoading {
                loadingRow
            } else if reports.isEmpty {
                emptyReportRow
            } else {
                reportsList
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Performans Sorguları")
                    .font(.system(size: 17, weight: .bold))

                Text(reports.isEmpty ? "Rapor geçmişi bulunmuyor" : "\(reports.count) rapor listeleniyor")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onCreateQuery) {
                HStack(spacing: 7) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13, weight: .semibold))

                    Text("Sorgu")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.10))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Reports

    private var reportsList: some View {
        VStack(spacing: 0) {
            ForEach(reports) { report in
                PerformanceReportRow(report: report) {
                    onSelectReport(report.id)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - States

    private var loadingRow: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Raporlar yükleniyor...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyReportRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text("Henüz rapor yok")
                    .font(.system(size: 15, weight: .semibold))

                Text("Tarih aralığı seçip performans sorgusu oluştur.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func errorRow(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Performance Report Row

private struct PerformanceReportRow: View {

    let report: PerformanceReportDTO
    let onTap: () -> Void

    private var score: Int {
        report.score ?? 0
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 13) {

                ScoreMiniGauge(score: score)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Sorgu Aralığı")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        statusPill
                    }

                    Text(ISODate.shortRange(start: report.startDate, end: report.endDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(scoreLevel(score))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(scoreColor(score))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color(.systemBackground))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.055))
                    .frame(height: 0.7)
                    .padding(.leading, 70)
            }
        }
        .buttonStyle(.plain)
    }

    private var statusPill: some View {
        Text("\(score) gün")
            .font(.caption2.weight(.bold))
            .foregroundStyle(scoreColor(score))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(scoreColor(score).opacity(0.12))
            )
    }
}

// MARK: - Mini Radial Gauge

private struct ScoreMiniGauge: View {

    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 6)

            Circle()
                .trim(from: 0, to: min(CGFloat(score) / 100, 1))
                .stroke(
                    scoreColor(score),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(score)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: 46, height: 46)
    }
}

// MARK: - Score Helpers

private func scoreLevel(_ score: Int) -> String {
    switch score {
    case 0..<40:
        return "Zayıf"
    case 40..<70:
        return "Orta"
    case 70..<85:
        return "İyi"
    default:
        return "Mükemmel"
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
