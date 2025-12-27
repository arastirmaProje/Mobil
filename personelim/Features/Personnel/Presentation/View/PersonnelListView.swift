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
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)

                        TextField("Ara", text: $vm.query)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                    Menu {
                        Picker("Sırala", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { opt in
                                Label(opt.title, systemImage: opt.systemImage).tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 18, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
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

                    Button {
                        showAddEmployee = true
                    } label: {
                        Text("Ekle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                Text("Personellerim")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)

                if vm.isLoading {
                    ProgressView().padding(.top, 20)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                List {
                    let base = vm.filtered(appState.businessMembers)
                    let sorted = sortMembers(base, by: sortOption)

                    ForEach(sorted) { m in
                        NavigationLink {
                            PersonnelDetailView(memberId: m.id)
                        } label: {
                            PersonnelRow(member: m)
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

private struct PersonnelRow: View {
    let member: BusinessMemberDTO

    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(member.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let p = member.position, !p.isEmpty {
                        pill(text: p, systemImage: "briefcase.fill")
                    }
                    if let s = member.salary {
                        pill(text: "\(Int(s)) TL", systemImage: "turkishlirasign")
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func pill(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.systemGray6).opacity(0.65))
        .clipShape(Capsule())
    }
}
