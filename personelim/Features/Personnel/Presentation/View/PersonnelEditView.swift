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
        VStack(spacing: 0) {

            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Personel düzenle")
                        .font(.title2.weight(.semibold))
                        .padding(.top, 8)

                    field(title: "Ünvan", text: $vm.position)
                    field(title: "Gelir", text: $vm.salaryText, keyboard: .numberPad)

                    if vm.isLoading {
                        ProgressView().padding(.top, 6)
                    }

                    if let err = vm.errorMessage {
                        Text(err).foregroundColor(.red)
                    }

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Text("Personeli Sil")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.red)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
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

        .alert("Personeli silmek istiyor musun?", isPresented: $showDeleteConfirm) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task { await vm.delete(memberId: memberId) }
            }
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }

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
                Task { await vm.save(memberId: memberId, original: originalMember) }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
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
            .disabled(vm.isLoading)
            .opacity(vm.isLoading ? 0.55 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }


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
