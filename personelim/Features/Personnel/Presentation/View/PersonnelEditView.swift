import SwiftUI

struct PersonnelEditView: View {

    @Environment(\.dismiss) private var dismiss

    let memberId: String
    let originalMember: BusinessMemberDTO
    let onSaved: () -> Void
    let onDeleted: () -> Void

    @StateObject private var vm: PersonnelEditViewModel
    @State private var showDeleteConfirm = false

    init(
        memberId: String,
        originalMember: BusinessMemberDTO,
        onSaved: @escaping () -> Void,
        onDeleted: @escaping () -> Void
    ) {
        self.memberId = memberId
        self.originalMember = originalMember
        self.onSaved = onSaved
        self.onDeleted = onDeleted

        let repo = BusinessMemberRepositoryImpl(network: NetworkManager())
        let updateUC = UpdateBusinessMemberUseCase(repo: repo)
        let deleteUC = DeleteBusinessMemberUseCase(repo: repo)

        _vm = StateObject(wrappedValue: PersonnelEditViewModel(
            updateUseCase: updateUC,
            deleteUseCase: deleteUC
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

        
                Text(ConstantStrings.editPersonnelTitle)
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Fields
     
                field(title: ConstantStrings.positionField, text: $vm.position)
 
                field(title: ConstantStrings.salaryField, text: $vm.salaryText, keyboard: .numberPad)

                if vm.isLoading { ProgressView() }

                // MARK: - Delete Button
                Button {
                    showDeleteConfirm = true
                } label: {
                    Text(ConstantStrings.deletePersonnelButton)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.red)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await vm.save(memberId: memberId, original: originalMember) }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(vm.isLoading)
                }
            }
        }
        .onAppear { vm.prefill(from: originalMember) }
        .onChange(of: vm.updatedMember?.id) { _, newValue in
            guard newValue != nil else { return }
            onSaved()
            dismiss()
        }
        .onChange(of: vm.didDelete) { _, newValue in
            guard newValue else { return }
            onDeleted()
            dismiss()
        }
        // Alert Metinleri Güncellendi
        .alert(ConstantStrings.deleteAlertTitle, isPresented: $showDeleteConfirm) {
            Button(ConstantStrings.cancel, role: .cancel) { }
            Button(ConstantStrings.delete, role: .destructive) {
                Task { await vm.delete(memberId: memberId) }
            }
        } message: {
            Text(ConstantStrings.deleteAlertMessage)
        }
    }

    // MARK: - Field helper
    private func field(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            TextField("", text: text)
                .keyboardType(keyboard)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
