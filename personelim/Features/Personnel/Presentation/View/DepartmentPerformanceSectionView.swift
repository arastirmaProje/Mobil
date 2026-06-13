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

    @State private var selectedReportId: String?
    @State private var showQuery = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            querySection
        }
        .task {
            await vm.loadReports(
                businessId: businessId,
                departmentId: departmentId
            )
        }
        .navigationDestination(
            isPresented: Binding(
                get: { selectedReportId != nil },
                set: { if !$0 { selectedReportId = nil } }
            )
        ) {
            if let reportId = selectedReportId {
                DepartmentReportDetailView(reportId: reportId)
            }
        }
        .sheet(isPresented: $showQuery) {
            DepartmentPerformanceQueryView(
                businessId: businessId,
                departmentId: departmentId,
                onCreated: {
                    Task {
                        await vm.loadReports(
                            businessId: businessId,
                            departmentId: departmentId
                        )
                    }
                }
            )
            .presentationDetents([.large])
        }
    }

    // MARK: - Query Section

    private var querySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.departmentPerformanceQueriesTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(
                        vm.reports.isEmpty
                        ? ConstantStrings.departmentPerformanceNoReportsText
                        : String(
                            format: ConstantStrings.departmentPerformanceListedReportsFormat,
                            vm.reports.count
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showQuery = true
                } label: {
                    Label(
                        ConstantStrings.departmentPerformanceQueryButton,
                        systemImage: "sparkle.magnifyingglass"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
                }
                .buttonStyle(.plain)
                .disabled(vm.isLoading)
            }

            if vm.isReportsLoading {
                reportsLoadingCard
            }

            if vm.reports.isEmpty && !vm.isReportsLoading {
                emptyReportCard
            } else {
                reportsList
            }
        }
    }

    // MARK: - Reports List

    private var reportsList: some View {
        VStack(spacing: 0) {
            ForEach(vm.reports) { report in
                DepartmentReportCard(
                    report: report,
                    dateRange: vm.formattedDateRange(
                        start: report.periodStart,
                        end: report.periodEnd
                    ),
                    statusText: vm.statusText(for: report.departmanSkoru)
                ) {
                    selectedReportId = report.id
                }

                if report.id != vm.reports.last?.id {
                    Divider()
                        .padding(.leading, 70)
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

    // MARK: - State Cards

    private var reportsLoadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.departmentPerformanceLoadingReportsText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyReportCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.noReportsAvailable)
                    .font(.system(size: 15, weight: .semibold))

                Text(ConstantStrings.createQueryInstruction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Department Report Card

private struct DepartmentReportCard: View {

    let report: DepartmentReportHistoryDTO
    let dateRange: String
    let statusText: String
    let onTap: () -> Void

    private var score: Int {
        Int(report.departmanSkoru.rounded())
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 13) {
                ScoreMiniGauge(score: score)

                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.departmentPerformanceQueryRangeTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(dateRange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(statusText)
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
        }
        .buttonStyle(.plain)
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
