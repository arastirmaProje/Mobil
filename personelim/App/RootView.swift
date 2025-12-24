import SwiftUI

struct RootView: View {

    @EnvironmentObject var appState: AppState

    private let network = NetworkManager()

    private var authRepo: AuthRepositoryProtocol { AuthRepositoryImpl(network: network) }
    private var businessRepo: BusinessRepositoryProtocol { BusinessRepositoryImpl(networkManager: network) }
    private var memberRepo: BusinessMemberRepositoryProtocol { BusinessMemberRepositoryImpl(network: network) }

    @State private var didBootstrap = false

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .task {
            guard !didBootstrap else { return }
            didBootstrap = true

            await appState.bootstrap(
                authRepository: authRepo,
                businessRepository: businessRepo,
                businessMemberRepository: memberRepo
            )
        }
    }
}
