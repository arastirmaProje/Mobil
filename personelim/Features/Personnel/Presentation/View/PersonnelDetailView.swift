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

        _vm = StateObject(
            wrappedValue: PersonnelDetailViewModel(
                getMemberUseCase: getMember,
                getReportsUseCase: getReports
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    if vm.isLoading {
                        loadingCard
                    }

                    if let err = vm.errorMessage {
                        errorCard(err)
                    }

                    if let member = vm.member {
                        header(member)
                        detailFields(member)
                        querySection
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Personel Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEdit = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .semibold))
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
        .navigationDestination(
            isPresented: Binding(
                get: { selectedReportId != nil },
                set: { if !$0 { selectedReportId = nil } }
            )
        ) {
            if let reportId = selectedReportId {
                PerformanceReportDetailView(reportId: reportId)
            }
        }
        .sheet(isPresented: $showQuery) {
            if let businessId = appState.businessId,
               let userId = vm.member?.userId {
                PerformanceQueryView(
                    businessId: businessId,
                    employeeUserId: userId,
                    onCreated: { _ in
                        Task {
                            await vm.loadReports(
                                businessId: businessId,
                                employeeUserId: userId
                            )
                        }
                    }
                )
                .presentationDetents([.large])
            }
        }
        .sheet(isPresented: $showEdit) {
            if let member = vm.member {
                PersonnelEditView(
                    memberId: memberId,
                    originalMember: member,
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

    private func loadReportsIfPossible() async {
        guard let businessId = appState.businessId,
              let userId = vm.member?.userId else {
            return
        }

        await vm.loadReports(
            businessId: businessId,
            employeeUserId: userId
        )
    }

    // MARK: - Header

    private func header(_ member: BusinessMemberDTO) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                avatar(member)

                VStack(alignment: .leading, spacing: 6) {
                    Text(member.fullName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("\(ConstantStrings.positionPrefix)\(member.positionName ?? "-")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    let salaryText = member.salary.map { "\(Int($0)) TL" } ?? "-"

                    Text("\(ConstantStrings.incomePrefix)\(salaryText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                miniInfoPill(
                    text: member.positionName ?? "-",
                    icon: "briefcase.fill",
                    color: .blue
                )

                if let salary = member.salary {
                    miniInfoPill(
                        text: "\(Int(salary)) TL",
                        icon: "turkishlirasign",
                        color: .green
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func avatar(_ member: BusinessMemberDTO) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Text(initials(from: member.fullName))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.blue)
        }
        .frame(width: 64, height: 64)
    }

    private func miniInfoPill(
        text: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))

            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
    }

    // MARK: - Detail Fields

    private func detailFields(_ member: BusinessMemberDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personel Bilgileri")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 2)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                PersonnelStatCard(
                    title: ConstantStrings.identityLabel,
                    value: member.tcIdentityNumber ?? "-",
                    icon: "person.text.rectangle"
                )

                PersonnelStatCard(
                    title: ConstantStrings.remainingLeaveLabel,
                    value: "4",
                    icon: "calendar.badge.clock"
                )

                PersonnelStatCard(
                    title: ConstantStrings.resumeLabel,
                    value: "Resume",
                    icon: "doc.text"
                )

                PersonnelStatCard(
                    title: ConstantStrings.documentsLabel,
                    value: member.documents?.first?.fileName ?? "-",
                    icon: "folder"
                )
            }
        }
    }

    // MARK: - Query Section

    private var querySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.querySectionTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(vm.reports.isEmpty ? "Rapor geçmişi bulunmuyor" : "\(vm.reports.count) rapor listeleniyor")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showQuery = true
                } label: {
                    Label("Sorgu", systemImage: "sparkle.magnifyingglass")
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
            }

            if vm.isReportsLoading {
                reportsLoadingCard
            }

            if let err = vm.reportsError {
                errorCard(err)
            }

            if vm.reports.isEmpty && !vm.isReportsLoading {
                emptyReportCard
            } else {
                reportsList
            }
        }
    }

    private var reportsList: some View {
        VStack(spacing: 0) {
            ForEach(vm.reports) { report in
                PerformanceReportCard(report: report) {
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

    private var reportsLoadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Raporlar yükleniyor...")
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

    // MARK: - State Cards

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Personel bilgileri yükleniyor...")
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

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name
            .split(separator: " ")
            .map(String.init)

        let first = parts.first?.first.map(String.init) ?? ""
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""

        let result = first + second
        return result.isEmpty ? "?" : result.uppercased()
    }
}

// MARK: - Personnel Stat Card

private struct PersonnelStatCard: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Performance Report Card

private struct PerformanceReportCard: View {

    let report: PerformanceReportDTO
    let onTap: () -> Void

    private var score: Int {
        report.score ?? 0
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 13) {
                ScoreMiniGauge(score: score)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(ConstantStrings.queryRangeLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        scorePill
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
        }
        .buttonStyle(.plain)
    }

    private var scorePill: some View {
        Text("\(score)")
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
        return ConstantStrings.performanceWeak
    case 40..<70:
        return ConstantStrings.performanceMedium
    case 70..<85:
        return ConstantStrings.performanceGood
    default:
        return ConstantStrings.performanceExcellent
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
