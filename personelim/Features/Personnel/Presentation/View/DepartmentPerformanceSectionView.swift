//
//  DepartmentPerformanceSectionView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import SwiftUI

struct DepartmentPerformanceSectionView: View {

    @ObservedObject var vm: DepartmentPerformanceViewModel

    let businessId: String
    let departmentId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            header

            dateSection

            if vm.isLoading {
                loadingRow
            }

            if let error = vm.errorMessage {
                errorRow(error)
            }

            if let report = vm.report {
                reportContent(report)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.departmentPerformanceTitle)
                    .font(.system(size: 18, weight: .bold))

                Text(ConstantStrings.createDepartmentReportButton)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task {
                    await vm.load(
                        businessId: businessId,
                        departmentId: departmentId
                    )
                }
            } label: {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(vm.isLoading)
        }
    }

    private var dateSection: some View {
        VStack(spacing: 10) {
            DatePicker(
                ConstantStrings.startDateLabel,
                selection: $vm.startDate,
                displayedComponents: .date
            )

            DatePicker(
                ConstantStrings.endDateLabel,
                selection: $vm.endDate,
                displayedComponents: .date
            )
        }
        .font(.subheadline)
    }

    private var loadingRow: some View {
        HStack(spacing: 10) {
            ProgressView()

            Text(ConstantStrings.loadingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func errorRow(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func reportContent(_ report: DepartmentPerformanceResponseDTO) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            scoreCards(report)

            taskDistribution(report.grafikVerisi.gorevDagilimi)

            employeeScores(report.calisanSkorlari)

            textBlock(
                title: ConstantStrings.reportSummaryTitle,
                text: report.raporOzeti
            )

            textBlock(
                title: ConstantStrings.detailedReportTitle,
                text: report.detayliRapor
            )
        }
    }

    private func scoreCards(_ report: DepartmentPerformanceResponseDTO) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 10
        ) {
            metricCard(
                title: ConstantStrings.departmentScoreTitle,
                value: String(format: "%.1f", report.departmanSkoru),
                icon: "star.circle.fill"
            )

            metricCard(
                title: ConstantStrings.employeeCountTitle,
                value: "\(report.toplamCalisan)",
                icon: "person.2.fill"
            )

            metricCard(
                title: ConstantStrings.taskCompletionRateTitle,
                value: "\(Int(report.grafikVerisi.departmanMetrikleri.ortalamaTamamlanmaOrani))%",
                icon: "checkmark.circle.fill"
            )

            metricCard(
                title: ConstantStrings.productivityTitle,
                value: "\(Int(report.grafikVerisi.departmanMetrikleri.ortalamaVerimlilik))%",
                icon: "bolt.fill"
            )

            metricCard(
                title: ConstantStrings.workUsageTitle,
                value: "\(Int(report.grafikVerisi.departmanMesaiOzeti.mesaiKullanimOrani))%",
                icon: "clock.fill"
            )
        }
    }

    private func metricCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)

            Text(value)
                .font(.system(size: 20, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func taskDistribution(_ data: GorevDagilimiDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ConstantStrings.taskDistributionTitle)
                .font(.headline)

            HStack(spacing: 10) {
                smallStat(
                    title: ConstantStrings.completedTaskTitle,
                    value: "\(data.toplamTamamlanan)"
                )

                smallStat(
                    title: ConstantStrings.failedTaskTitle,
                    value: "\(data.toplamTamamlanamayan)"
                )

                smallStat(
                    title: ConstantStrings.totalTaskTitle,
                    value: "\(data.toplamGorev)"
                )
            }
        }
    }

    private func smallStat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func employeeScores(_ scores: [CalisanSkorDTO]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ConstantStrings.employeeScoresTitle)
                .font(.headline)

            if scores.isEmpty {
                Text(ConstantStrings.noDataText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(scores) { item in
                    HStack {
                        Text(item.adSoyad)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Text(String(format: "%.1f", item.performansSkoru))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func textBlock(
        title: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
