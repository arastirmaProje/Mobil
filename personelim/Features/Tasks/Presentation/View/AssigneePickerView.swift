import SwiftUI

struct AssigneePickerView: View {

    let members: [BusinessMemberDTO]
    @Binding var selectedAssignees: Set<String>
    let onDone: () -> Void

    @State private var searchText = ""

    private var filteredMembers: [BusinessMemberDTO] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return members
        }

        return members.filter { member in
            member.fullName.localizedCaseInsensitiveContains(query)
            || (member.position ?? "").localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerSection
                    searchSection

                    if filteredMembers.isEmpty {
                        emptyState
                    } else {
                        membersSection
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }

            bottomDoneButton
        }
        .navigationTitle(ConstantStrings.assigneePickerTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "person.2.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.assigneePickerTitle)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.primary)

                Text(
                    selectedAssignees.isEmpty
                    ? ConstantStrings.noAssigneeSelected
                    : String(format: ConstantStrings.assigneeSelectedCountFormat, selectedAssignees.count)
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(ConstantStrings.employeeSearchPlaceholder, text: $searchText)
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.words)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ConstantStrings.employeesHeader)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(filteredMembers.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .padding(.horizontal, 2)

            VStack(spacing: 0) {
                ForEach(filteredMembers, id: \.userId) { member in
                    memberRow(member)

                    if member.userId != filteredMembers.last?.userId {
                        Divider()
                            .padding(.leading, 62)
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
    }

    private func memberRow(_ member: BusinessMemberDTO) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                toggle(member.userId)
            }
        } label: {
            HStack(spacing: 12) {
                avatar(member)

                VStack(alignment: .leading, spacing: 3) {
                    Text(member.fullName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(member.position ?? ConstantStrings.dashPlaceholder)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if isSelected(member.userId) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.blue)
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.14), lineWidth: 1.4)
                        .frame(width: 21, height: 21)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                isSelected(member.userId)
                ? Color.blue.opacity(0.035)
                : Color(.systemBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func avatar(_ member: BusinessMemberDTO) -> some View {
        let initials = initials(from: member.fullName)

        return ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Text(initials)
                .font(.caption.weight(.bold))
                .foregroundStyle(.blue)
        }
        .frame(width: 38, height: 38)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.employeeNotFound)
                .font(.headline)

            Text(ConstantStrings.searchRetryHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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

    private var bottomDoneButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                onDone()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")

                    Text(ConstantStrings.doneButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    private func isSelected(_ id: String) -> Bool {
        selectedAssignees.contains(id)
    }

    private func toggle(_ id: String) {
        if selectedAssignees.contains(id) {
            selectedAssignees.remove(id)
        } else {
            selectedAssignees.insert(id)
        }
    }

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
