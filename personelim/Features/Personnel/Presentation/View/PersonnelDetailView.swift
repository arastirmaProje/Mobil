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
        VStack(spacing: 0) {

            topBar

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
        }
        .navigationBarHidden(true)
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
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Yükleniyor...")
                        .foregroundColor(.gray)
                }
                .presentationDetents([.medium])
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
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Yükleniyor...")
                        .foregroundColor(.gray)
                }
                .presentationDetents([.medium])
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

    private var topBar: some View {
        HStack(spacing: 12) {

            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showEdit = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Düzenle")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(vm.member == nil)
            .opacity(vm.member == nil ? 0.55 : 1.0)

        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

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
            LabeledCard(title: "Kimlik", value: m.tcIdentityNumber ?? "-")
            LabeledCard(title: "CV", value: "Resume") // placeholder
            LabeledCard(title: "Belgeler", value: (m.documents?.first?.fileName ?? "-"))
            LabeledCard(title: "Kalan izin günü", value: "4") // placeholder
        }
    }

    private var querySection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Sorgu")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button {
                    showQuery = true
                } label: {
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

// MARK: - Small reusable card
private struct LabeledCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct PerformanceReportCard: View {
    let report: PerformanceReportDTO
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
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
