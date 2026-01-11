//
//  PersonnelDetailView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

struct PersonnelDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let memberId: String

    @StateObject private var vm: PersonnelDetailViewModel
    @State private var showEdit = false
    @State private var showQuery = false
    @State private var selectedReportId: String?

    init(memberId: String) {
        self.memberId = memberId

        let network = NetworkManager()

        let memberRepo = BusinessMemberRepositoryImpl(network: network)
        let getMember = GetBusinessMemberUseCase(repo: memberRepo)

        let perfRepo = PerformanceRepositoryImpl(network: network)
        let getReports = GetPerformanceReportsUseCase(repo: perfRepo)

        _vm = StateObject(wrappedValue: PersonnelDetailViewModel(
            getMemberUseCase: getMember,
            getReportsUseCase: getReports
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    header

                    if vm.isLoading {
                        ProgressView().padding(.top, 16)
                    }

                    if let err = vm.errorMessage {
                        Text(err).foregroundColor(.red)
                    }

                    if let m = vm.member {
                        detailFields(m)  
                        querySection
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .disabled(vm.member == nil)
                }
            }
            .task {
                await vm.load(memberId: memberId)
                await loadReportsIfPossible()
            }
            .refreshable {
                await vm.load(memberId: memberId)
                await loadReportsIfPossible()
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedReportId != nil },
                set: { if !$0 { selectedReportId = nil } }
            )) {
                if let rid = selectedReportId {
                    PerformanceReportDetailView(reportId: rid)
                }
            }
            .sheet(isPresented: $showQuery) {
                if let bid = appState.businessId,
                   let uid = vm.member?.userId {
                    PerformanceQueryView(
                        businessId: bid,
                        employeeUserId: uid,
                        onCreated: { _ in
                            Task { await vm.loadReports(businessId: bid, employeeUserId: uid) }
                        }
                    )
                    .presentationDetents([.large])
                }
            }
            .sheet(isPresented: $showEdit) {
                if let m = vm.member {
                    PersonnelEditView(
                        memberId: memberId,
                        originalMember: m,
                        onSaved: {
                            Task {
                                await vm.load(memberId: memberId)
                                await loadReportsIfPossible()
                            }
                        },
                        onDeleted: {
                            dismiss()
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadReportsIfPossible() async {
        guard let bid = appState.businessId,
              let uid = vm.member?.userId else { return }
        await vm.loadReports(businessId: bid, employeeUserId: uid)
    }

    // MARK: - UI Parts

    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.member?.fullName ?? "—")
                    .font(.system(size: 20, weight: .semibold))

                Text("Ünvan: \(vm.member?.position ?? "-")")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                let salaryText = vm.member?.salary.map { "\(Int($0)) TL" } ?? "-"
                Text("Gelir: \(salaryText)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.top, 4)
    }

    private func detailFields(_ m: BusinessMemberDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoCard(title: "Kimlik", value: m.tcIdentityNumber ?? "-")
            InfoCard(title: "CV", value: "Resume")
            InfoCard(title: "Belgeler", value: (m.documents?.first?.fileName ?? "-"))
            InfoCard(title: "Kalan izin günü", value: "4")
        }
    }

    // MARK: - Query Section (rapor kartları)

    private var querySection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Sorgu")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button { showQuery = true } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            .padding(.top, 6)

            if vm.isReportsLoading {
                ProgressView().padding(.top, 8)
            }

            if let err = vm.reportsError {
                Text(err).foregroundColor(.red)
            }

            if vm.reports.isEmpty && !vm.isReportsLoading {
                emptyReportCard
            } else {
                VStack(spacing: 10) {
                    ForEach(vm.reports) { r in
                        PerformanceReportCard(report: r) {
                            selectedReportId = r.id
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

// MARK: - Performance Report Card

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

// MARK: - Mini Radial Gauge

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

// MARK: - Info Card

private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
        }
    }
}
