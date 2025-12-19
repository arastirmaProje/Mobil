import SwiftUI

struct LoginView: View {

    @StateObject private var vm = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var goToResetPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Text("Giriş Yapalım")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))

                        TextField("ornek@gmail.com", text: $vm.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Şifre")
                            .font(.system(size: 14, weight: .medium))

                        SecureField("123...", text: $vm.password)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                            )
                    }

                    HStack {
                        Button(action: { vm.rememberMe.toggle() }) {
                            Image(systemName: vm.rememberMe ? "checkmark.square" : "square")
                                .foregroundColor(.gray)
                        }
                        Text("Beni hatırla")
                            .font(.system(size: 14))
                    }

                    Button("Şifremi unuttum") {
                        goToResetPassword = true
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)

                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Button {
                    Task { await vm.login(appState: appState) }
                } label: {
                    Text("Giriş Yap")
                }
                .disabled(vm.isLoading)
                .buttonStyle(OnboardingButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .bottom)
            .fullScreenCover(isPresented: $vm.isLoggedIn) {
                MainTabView()
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $goToResetPassword) {
                ForgotPasswordView()
            }
        }
    }
}
