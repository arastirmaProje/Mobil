import SwiftUI

struct AddEmployeeView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    private let network = NetworkManager()
    private var invitationRepo: InvitationRepositoryProtocol { InvitationRepositoryImpl(network: network) }
    private var memberRepo: BusinessMemberRepositoryProtocol { BusinessMemberRepositoryImpl(network: network) }

    @StateObject private var vm: AddEmployeeViewModel

    init() {
        let useCase = SendInvitationUseCase(repo: InvitationRepositoryImpl(network: NetworkManager()))
        _vm = StateObject(wrappedValue: AddEmployeeViewModel(sendUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {

                Text(ConstantStrings.addEmployeeTitle)
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text(ConstantStrings.emailLabel).font(.system(size: 13, weight: .medium))
                    
                    TextField(ConstantStrings.emailPlaceholder, text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if vm.isLoading { ProgressView() }

                if let err = vm.errorMessage {
                    Text(err).foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let ok = vm.successMessage {
                    Text(ok).foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(16)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            guard let bid = appState.businessId else { return }
                            await vm.send(businessId: bid)

                            if vm.errorMessage == nil, vm.successMessage != nil {
                                await appState.refreshBusinessMembers(repository: memberRepo)
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    .disabled(vm.isLoading)
                }
            }
        }
    }
}
