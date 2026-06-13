import SwiftUI

struct DepartmentDetailView: View {

    let departmentId: String
    let departmentName: String
    let businessId: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @StateObject private var memberViewModel = BusinessMemberViewModel()
    @StateObject private var deptViewModel = DepartmentViewModel()
    @StateObject private var performanceVM = DepartmentPerformanceViewModel()

    @State private var showAddMemberSheet = false
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false

    private var filteredMembers: [BusinessMemberDTO] {
        memberViewModel.members.filter { $0.departmentId == departmentId }
    }

    var body: some View {
        ZStack {
           
       

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection

                    DepartmentPerformanceSectionView(
                        vm: performanceVM,
                        businessId: businessId,
                        departmentId: departmentId
                    )

                    employeesSection

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(ConstantStrings.departmentDetailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showAddMemberSheet = true
                    } label: {
                        Label(
                            ConstantStrings.addMemberAction,
                            systemImage: "person.badge.plus"
                        )
                    }

                    Button {
                        showEditSheet = true
                    } label: {
                        Label(
                            ConstantStrings.editDepartmentAction,
                            systemImage: "pencil"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label(
                            ConstantStrings.deleteDepartmentAction,
                            systemImage: "trash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
            }
        }
        .task {
            await memberViewModel.fetchMembers(businessId: businessId)
        }
        .sheet(isPresented: $showAddMemberSheet) {
            AddMemberView(
                businessId: businessId,
                departmentId: departmentId
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditDepartmentView(
                viewModel: deptViewModel,
                departmentId: departmentId,
                departmentName: departmentName,
                businessId: businessId,
                initialCategoryId: 1,
                onComplete: {
                    dismiss()
                }
            )
            .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            ConstantStrings.deleteDepartmentAction,
            isPresented: $showDeleteAlert,
            titleVisibility: .visible
        ) {
            Button(ConstantStrings.deleteButton, role: .destructive) {
                Task {
                    await deptViewModel.deleteDepartment(
                        id: departmentId,
                        businessId: businessId
                    )
                    dismiss()
                }
            }

            Button(ConstantStrings.cancelButton, role: .cancel) { }
        } message: {
            Text(ConstantStrings.deleteDepartmentConfirmation)
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding<Bool>(
                get: { deptViewModel.errorMessage != nil },
                set: { _ in deptViewModel.errorMessage = nil }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(deptViewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                departmentIcon

                VStack(alignment: .leading, spacing: 6) {
                    Text(departmentName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    
                }

                Spacer()
            }

          
        }
        .padding(16)
        .background(cardBackground(cornerRadius: 24))
    }

    private var departmentIcon: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Image(systemName: "building.2.fill")
                .font(.system(size: 22, weight: .semibold))
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

    // MARK: - Employees

    private var employeesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.employeesHeader)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(
                        String(
                            format: ConstantStrings.departmentEmployeeCountFormat,
                            filteredMembers.count
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showAddMemberSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.10))
                        )
                }
                .buttonStyle(.plain)
            }

            if filteredMembers.isEmpty {
                emptyEmployeeCard
            } else {
                employeesList
            }
        }
    }

    private var employeesList: some View {
        VStack(spacing: 0) {
            ForEach(filteredMembers) { member in
                NavigationLink {
                    PersonnelDetailView(memberId: member.id)
                } label: {
                    employeeRow(member)
                }
                .buttonStyle(.plain)

                if member.id != filteredMembers.last?.id {
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

    private func employeeRow(_ member: BusinessMemberDTO) -> some View {
        HStack(spacing: 13) {
            employeeAvatar(member.fullName)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.fullName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(member.positionName ?? ConstantStrings.defaultPosition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
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

    private func employeeAvatar(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Text(initials(from: name))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.blue)
        }
        .frame(width: 46, height: 46)
    }

    private var emptyEmployeeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.noEmployeesInDepartment)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.addMemberAction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 18))
    }

    // MARK: - Helpers

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.045), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
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
