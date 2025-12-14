import SwiftUI

struct LoginView: View {
    
    @StateObject private var vm = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Back Button
            HStack {
                Button(action:{ dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Title
            Text("Giriş Yapalım")
                .font(.title2.weight(.semibold))
                .padding(.top, 24)
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("damn@gmail.com", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                
                // Password
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
                
                // Remember Me
                HStack {
                    Button(action: { vm.rememberMe.toggle() }) {
                        Image(systemName: vm.rememberMe ? "checkmark.square" : "square")
                            .foregroundColor(.gray)
                    }
                    Text("Beni hatırla")
                        .font(.system(size: 14))
                }
                
                // Forgot Password
                Button("Şifremi unuttum") {}
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                
                // Error message (varsa)
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Login Button
            Button {
                Task { await vm.login() }
            } label: {
                Text(vm.isLoading ? "Giriş yapılıyor..." : "Giriş Yap")
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
        
        
        .fullScreenCover(isPresented: $vm.isLoggedIn) {
            MainTabView()
        }
    }
}
