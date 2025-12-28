//
//  PerformanceSectionView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 28.12.2025.
//

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
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Sorgu")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1))
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)

            if isLoading {
                ProgressView().padding(.top, 8)
            }

            if let error {
                Text(error).foregroundColor(.red)
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

// MARK: - Internal Cards
private struct PerformanceReportCard: View {
    let report: PerformanceReportDTO
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
                .frame(height: 74)
                .overlay(
                    HStack(spacing: 12) {

                        ScoreMini(score: report.score ?? 0)

                        VStack(alignment: .leading, spacing: 4) {
                            Text((report.createdByName ?? "—") + " tarafından")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text(ISODate.shortRange(start: report.startDate, end: report.endDate))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ScoreMini: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 44, height: 44)

            Text("\(score)")
                .font(.system(size: 14, weight: .semibold))
        }
    }
}
