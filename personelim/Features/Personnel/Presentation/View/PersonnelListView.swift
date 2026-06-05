import SwiftUI

struct PersonnelListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = PersonnelListViewModel()

    @State private var showAddEmployee = false
    @State private var showBulkQuerySheet = false
    @State private var selectedMember: BusinessMemberDTO?

    private enum SortOption: String, CaseIterable {
        case nameAZ
        case nameZA
        case salaryHighLow
        case salaryLowHigh

        var title: String {
            switch self {
            case .nameAZ: return ConstantStrings.sortNameAZ
            case .nameZA: return ConstantStrings.sortNameZA
            case .salaryHighLow: return ConstantStrings.sortSalaryHighLow
            case .salaryLowHigh: return ConstantStrings.sortSalaryLowHigh
            }
        }

        var systemImage: String {
            switch self {
            case .nameAZ, .nameZA:
                return "textformat.abc"
            case .salaryHighLow, .salaryLowHigh:
                return "turkishlirasign.circle"
            }
        }
    }

    @State private var sortOption: SortOption = .nameAZ

    private let network = NetworkManager()

    private var memberRepo: BusinessMemberRepositoryProtocol {
        BusinessMemberRepositoryImpl(network: network)
    }

    private var sortedMembers: [BusinessMemberDTO] {
        let base = vm.filtered(appState.businessMembers)
        return sortMembers(base, by: sortOption)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    headerSection

                    searchActionSection

                    statusMessages

                    personnelList
                }
                .padding(.top, 12)
            }
            .navigationBarHidden(true)
            .navigationDestination(
                isPresented: Binding(
                    get: {
                        selectedMember != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            selectedMember = nil
                        }
                    }
                )
            ) {
                if let member = selectedMember {
                    PersonnelDetailView(memberId: member.id)
                }
            }
            .task {
                vm.isLoading = true
                defer { vm.isLoading = false }

                await appState.loadBusinessMembersIfNeeded(
                    repository: memberRepo
                )
            }
            .sheet(isPresented: $showAddEmployee) {
                AddEmployeeView()
            }
            .sheet(isPresented: $showBulkQuerySheet) {
                bulkQuerySheet
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.myPersonnelTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)

                Text("\(sortedMembers.count) personel listeleniyor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showBulkQuerySheet = true
            } label: {
                HStack(spacing: 7) {
                    if vm.isBulkLoading {
                        ProgressView()
                            .scaleEffect(0.82)
                    } else {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    Text(ConstantStrings.bulkQueryTitle)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.10))
                )
                .opacity((vm.isBulkLoading || appState.businessId == nil) ? 0.55 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(vm.isBulkLoading || appState.businessId == nil)
        }
        .padding(.horizontal, 18)
    }

    // MARK: - Search / Actions

    private var searchActionSection: some View {
        HStack(spacing: 10) {
            searchBox

            sortMenu

            Button {
                showAddEmployee = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
    }

    private var searchBox: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(ConstantStrings.searchPlaceholder, text: $vm.query)
                .textInputAutocapitalization(.never)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)

            if !vm.query.isEmpty {
                Button {
                    vm.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var sortMenu: some View {
        Menu {
            Picker(ConstantStrings.sortTitle, selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.10))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status

    @ViewBuilder
    private var statusMessages: some View {
        if vm.isLoading {
            loadingCard
                .padding(.horizontal, 18)
        }

        if let err = vm.errorMessage {
            errorCard(err)
                .padding(.horizontal, 18)
        }

        if let bulkError = vm.bulkError {
            errorCard(bulkError)
                .padding(.horizontal, 18)
        }
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Personeller yükleniyor...")
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

    // MARK: - List

    private var personnelList: some View {
        List {
            if !vm.isLoading && sortedMembers.isEmpty {
                emptyState
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(
                            top: 24,
                            leading: 18,
                            bottom: 16,
                            trailing: 18
                        )
                    )
            } else {
                ForEach(sortedMembers) { member in
                    Button {
                        selectedMember = member
                    } label: {
                        PersonnelRow(
                            member: member,
                            scoreText: vm.scoreText(for: member)
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(
                            top: 6,
                            leading: 18,
                            bottom: 6,
                            trailing: 18
                        )
                    )
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .refreshable {
            await appState.refreshBusinessMembers(repository: memberRepo)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.blue)

            Text("Personel bulunamadı")
                .font(.headline)

            Text(vm.query.isEmpty
                 ? "Yeni personel ekleyerek listeyi oluşturmaya başlayabilirsin."
                 : "Arama kriterini değiştirerek tekrar deneyebilirsin.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if vm.query.isEmpty {
                Button {
                    showAddEmployee = true
                } label: {
                    Label(ConstantStrings.addLabel, systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.10))
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Sheets

    @ViewBuilder
    private var bulkQuerySheet: some View {
        if let bid = appState.businessId {
            NavigationStack {
                PerformanceBulkQueryView(
                    businessId: bid,
                    vm: vm,
                    onCompleted: { _, _ in
                        showBulkQuerySheet = false
                    }
                )
            }
            .presentationDetents([.large])
        } else {
            VStack(spacing: 12) {
                ProgressView()

                Text(ConstantStrings.loading)
                    .foregroundStyle(.secondary)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Sorting Logic

    private func sortMembers(
        _ members: [BusinessMemberDTO],
        by option: SortOption
    ) -> [BusinessMemberDTO] {
        func normName(_ value: String) -> String {
            value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        }

        func salaryValue(_ member: BusinessMemberDTO) -> Double {
            member.salary ?? -1
        }

        return members.sorted { first, second in
            let firstName = normName(first.fullName)
            let secondName = normName(second.fullName)

            switch option {
            case .nameAZ:
                return firstName == secondName
                    ? salaryValue(first) > salaryValue(second)
                    : firstName < secondName

            case .nameZA:
                return firstName == secondName
                    ? salaryValue(first) > salaryValue(second)
                    : firstName > secondName

            case .salaryHighLow:
                let firstSalary = salaryValue(first)
                let secondSalary = salaryValue(second)

                return firstSalary == secondSalary
                    ? firstName < secondName
                    : firstSalary > secondSalary

            case .salaryLowHigh:
                let firstSalary = salaryValue(first)
                let secondSalary = salaryValue(second)

                return firstSalary == secondSalary
                    ? firstName < secondName
                    : firstSalary < secondSalary
            }
        }
    }
}

// MARK: - Personnel Row

private struct PersonnelRow: View {

    let member: BusinessMemberDTO
    let scoreText: String?

    private var score: Int? {
        scoreText.flatMap { Int($0) }
    }

    var body: some View {
        HStack(spacing: 13) {
            if let score {
                ScoreMiniGauge(score: score)
            } else {
                avatarPlaceholder
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(member.fullName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let position = member.positionName, !position.isEmpty {
                        DetailPill(
                            text: position,
                            systemImage: "briefcase.fill",
                            color: .blue
                        )
                    }

                    if let salary = member.salary {
                        DetailPill(
                            text: "\(Int(salary)) TL",
                            systemImage: "turkishlirasign",
                            color: .green
                        )
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.025), radius: 8, y: 4)
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Image(systemName: "person.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.blue)
        }
        .frame(width: 46, height: 46)
    }

    private struct DetailPill: View {
        let text: String
        let systemImage: String
        let color: Color

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))

                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
        }
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
}
