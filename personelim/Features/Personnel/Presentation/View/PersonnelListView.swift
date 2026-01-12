//
//  PersonnelListView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

struct PersonnelListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = PersonnelListViewModel()

    @State private var showAddEmployee = false
    @State private var showBulkQuerySheet = false

    private enum SortOption: String, CaseIterable {
        case nameAZ, nameZA, salaryHighLow, salaryLowHigh

        var title: String {
            switch self {
            case .nameAZ: return "Ad (A → Z)"
            case .nameZA: return "Ad (Z → A)"
            case .salaryHighLow: return "Maaş (Yüksek → Düşük)"
            case .salaryLowHigh: return "Maaş (Düşük → Yüksek)"
            }
        }

        var systemImage: String {
            switch self {
            case .nameAZ, .nameZA: return "textformat.abc"
            case .salaryHighLow, .salaryLowHigh: return "turkishlirasign.circle"
            }
        }
    }

    @State private var sortOption: SortOption = .nameAZ

    private let network = NetworkManager()
    private var memberRepo: BusinessMemberRepositoryProtocol { BusinessMemberRepositoryImpl(network: network) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // MARK: - Search + Sort + Add
                HStack(spacing: 10) {

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)

                        TextField("Ara", text: $vm.query)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Menu {
                        Picker("Sırala", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { opt in
                                Label(opt.title, systemImage: opt.systemImage).tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button { showAddEmployee = true } label: {
                        Text("Ekle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // MARK: - Header + Bulk Query
                HStack {
                    Text("Personellerim")
                        .font(.title3.weight(.semibold))

                    Spacer()

                    Button { showBulkQuerySheet = true } label: {
                        HStack(spacing: 6) {
                            if vm.isBulkLoading {
                                ProgressView().scaleEffect(0.85)
                            } else {
                                Image(systemName: "sparkle.magnifyingglass")
                                    .font(.system(size: 12, weight: .semibold))
                            }

                            Text("Toplu Sorgu")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        .opacity((vm.isBulkLoading || appState.businessId == nil) ? 0.55 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.isBulkLoading || appState.businessId == nil)
                }
                .padding(.horizontal, 16)

                if vm.isLoading {
                    ProgressView().padding(.top, 20)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                if let e = vm.bulkError {
                    Text(e)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                // MARK: - List
                List {
                    let base = vm.filtered(appState.businessMembers)
                    let sorted = sortMembers(base, by: sortOption)

                    ForEach(sorted) { m in
                        NavigationLink {
                            PersonnelDetailView(memberId: m.id)
                        } label: {
                            PersonnelRow(
                                member: m,
                                scoreText: vm.scoreText(for: m)
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await appState.refreshBusinessMembers(repository: memberRepo)
                }
            }
            .navigationBarHidden(true)
            .task {
                vm.isLoading = true
                defer { vm.isLoading = false }
                await appState.loadBusinessMembersIfNeeded(repository: memberRepo)
            }
            .sheet(isPresented: $showAddEmployee) {
                AddEmployeeView()
            }
            .sheet(isPresented: $showBulkQuerySheet) {
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
                        Text("Yükleniyor...")
                            .foregroundColor(.gray)
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Sorting
    private func sortMembers(_ members: [BusinessMemberDTO], by option: SortOption) -> [BusinessMemberDTO] {
        func normName(_ s: String) -> String {
            s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        func salaryValue(_ m: BusinessMemberDTO) -> Double {
            m.salary ?? -1
        }

        return members.sorted { a, b in
            let an = normName(a.fullName)
            let bn = normName(b.fullName)

            switch option {
            case .nameAZ:
                return an == bn ? salaryValue(a) > salaryValue(b) : (an < bn)
            case .nameZA:
                return an == bn ? salaryValue(a) > salaryValue(b) : (an > bn)
            case .salaryHighLow:
                let sa = salaryValue(a), sb = salaryValue(b)
                return sa == sb ? (an < bn) : (sa > sb)
            case .salaryLowHigh:
                let sa = salaryValue(a), sb = salaryValue(b)
                return sa == sb ? (an < bn) : (sa < sb)
            }
        }
    }
}

// MARK: - Row with Modern Pill & Mini Gauge

private struct PersonnelRow: View {
    let member: BusinessMemberDTO
    let scoreText: String?

    var body: some View {
        HStack(spacing: 12) {

            if let score = scoreText.flatMap({ Int($0) }) {
                ScoreMiniGauge(score: score)
            } else {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {

                Text(member.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let p = member.position, !p.isEmpty {
                        DetailPill(text: p, systemImage: "briefcase.fill", color: .blue)
                    }
                    if let s = member.salary {
                        DetailPill(text: "\(Int(s)) TL", systemImage: "turkishlirasign", color: .green)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Modern Pill Tasarımı
    private struct DetailPill: View {
        let text: String
        let systemImage: String
        let color: Color

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(text)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
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

    private func scoreColor(_ s: Int) -> Color {
        switch s {
        case 0..<40: return .red
        case 40..<70: return .orange
        case 70..<85: return .blue
        default: return .green
        }
    }
}
