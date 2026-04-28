import SwiftUI

struct DepartmentDetailView: View {
    let departmentId: String
    let departmentName: String
    let businessId: String
    
    @StateObject private var memberViewModel = BusinessMemberViewModel()
    @StateObject private var deptViewModel = DepartmentViewModel()
    
    @State private var showAddMemberSheet = false
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section(header: Text(ConstantStrings.employeesHeader)) {
                let filteredMembers = memberViewModel.members.filter({ $0.departmentId == departmentId })
                
                if filteredMembers.isEmpty {
                    VStack(alignment: .center) {
                        Text(ConstantStrings.noEmployeesInDepartment)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    ForEach(filteredMembers) { member in
                        NavigationLink(destination: PersonnelDetailView(memberId: member.id)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.fullName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(member.positionName ?? ConstantStrings.defaultPosition)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle(departmentName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showAddMemberSheet = true }) {
                        Label(ConstantStrings.addMemberAction, systemImage: "person.badge.plus")
                    }
                    
                    Button(action: { showEditSheet = true }) {
                        Label(ConstantStrings.editDepartmentAction, systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label(ConstantStrings.deleteDepartmentAction, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddMemberSheet) {
            AddMemberView(businessId: businessId, departmentId: departmentId)
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
        .confirmationDialog(ConstantStrings.deleteDepartmentAction, isPresented: $showDeleteAlert, titleVisibility: .visible) {
            Button(ConstantStrings.deleteButton, role: .destructive) {
                Task {
                    await deptViewModel.deleteDepartment(id: departmentId, businessId: businessId)
                    dismiss()
                }
            }
            Button(ConstantStrings.cancelButton, role: .cancel) { }
        } message: {
            Text(ConstantStrings.deleteDepartmentConfirmation)
        }
        .task {
            await memberViewModel.fetchMembers(businessId: businessId)
        }
        .alert(ConstantStrings.errorTitle, isPresented: Binding<Bool>(
            get: { deptViewModel.errorMessage != nil },
            set: { _ in deptViewModel.errorMessage = nil }
        )) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(deptViewModel.errorMessage ?? "")
        }
    }
}
