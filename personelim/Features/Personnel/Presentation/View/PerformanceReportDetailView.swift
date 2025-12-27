//
//  PerformanceReportDetailView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

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

                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.systemGray6))
                            .frame(minHeight: 140)
                            .overlay(
                                Text(r.summaryText ?? "-")
                                    .font(.system(size: 14, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .padding(18)
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
