import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var jobTitleViewModel = JobTitleViewModel()
    @StateObject private var memberViewModel = BusinessMemberViewModel()
    
    let businessId: String
    let departmentId: String
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var salary = ""
    @State private var tcNo = ""
    @State private var selectedPositionId: Int = 0

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(ConstantStrings.personalInfoSectionHeader)) {
                    TextField(ConstantStrings.firstNameLabel, text: $firstName)
                    TextField(ConstantStrings.lastNameLabel, text: $lastName)
                    TextField(ConstantStrings.emailLabel, text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField(ConstantStrings.tcNoLabel, text: $tcNo)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text(ConstantStrings.jobInfoSectionHeader)) {
                    Picker(ConstantStrings.positionLabel, selection: $selectedPositionId) {
                        Text(ConstantStrings.selectEmployeePlaceholder).tag(0)
                        ForEach(jobTitleViewModel.jobTitles) { title in
                            Text(title.name).tag(title.id)
                        }
                    }
                    
                    TextField(ConstantStrings.salaryPlaceholder, text: $salary)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(ConstantStrings.addMemberNavTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ConstantStrings.closeButton) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ConstantStrings.addButton) {
                        addMemberAction()
                    }
                    .disabled(!isFormValid)
                }
            }
            .task {
                await jobTitleViewModel.fetchJobTitlesByDepartment(departmentId: departmentId)
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && email.contains("@") && selectedPositionId != 0
    }
    
    private func addMemberAction() {
        let request = CreateMemberRequestDTO(
            businessId: businessId,
            email: email,
            firstName: firstName,
            lastName: lastName,
            positionId: selectedPositionId,
            departmentId: departmentId,
            salary: Double(salary) ?? 0.0,
            tcIdentityNumber: tcNo.isEmpty ? nil : tcNo
        )
        
        Task {
            await memberViewModel.addMember(request: request)
            dismiss()
        }
    }
}
