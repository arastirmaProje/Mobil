import SwiftUI

struct OnboardingView: View {

    @State private var appear = false
    @State private var iconPulse = false
    @State private var floatIcon = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBlobBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 70)

                    heroSection

                    Spacer()

                    actionButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 26)
                }
            }
            .onAppear {
                appear = false
                iconPulse = false
                floatIcon = false

                withAnimation(.easeOut(duration: 0.75).delay(0.12)) {
                    appear = true
                }

                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    iconPulse = true
                }

                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    floatIcon = true
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 22) {
            appIcon

            VStack(spacing: 10) {
                Text(ConstantStrings.appName)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 16)

                Text(ConstantStrings.onboardingDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 34)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 18)
            }

            featurePills
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
        }
        .padding(.top, 20)
    }

    private var appIcon: some View {
        ZStack {
            Circle()
                .fill(.regularMaterial)
                .frame(width: 126, height: 126)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 24, y: 14)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.95),
                            Color.purple.opacity(0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: iconPulse ? 86 : 78, height: iconPulse ? 86 : 78)
                .shadow(color: .blue.opacity(0.25), radius: 18, y: 8)

            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .offset(y: floatIcon ? -4 : 4)
        }
        .scaleEffect(appear ? 1 : 0.82)
        .opacity(appear ? 1 : 0)
    }

    private var featurePills: some View {
        HStack(spacing: 8) {
            pill(ConstantStrings.onboardingShiftPill, "clock.fill")
            pill(ConstantStrings.onboardingLeavePill, "calendar.badge.checkmark")
            pill(ConstantStrings.onboardingPerformancePill, "chart.line.uptrend.xyaxis")
        }
        .padding(.horizontal, 18)
    }

    private func pill(_ text: String, _ icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))

            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.blue)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.72))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink {
                LoginView()
            } label: {
                Label(ConstantStrings.loginButton, systemImage: "arrow.right.circle.fill")
            }
            .buttonStyle(OnboardingButtonStyle(kind: .primary))
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 24)

            NavigationLink {
                SignupView()
            } label: {
                Label(ConstantStrings.createCompanyTitle, systemImage: "building.2.fill")
            }
            .buttonStyle(OnboardingButtonStyle(kind: .secondary))
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 28)
        }
        .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.22), value: appear)
    }
}

// MARK: - Button Style

struct OnboardingButtonStyle: ButtonStyle {

    enum Kind {
        case primary
        case secondary
    }

    let kind: Kind

    init(kind: Kind = .primary) {
        self.kind = kind
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(kind == .primary ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        kind == .primary
                        ? Color.clear
                        : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: kind == .primary
                ? Color.blue.opacity(0.26)
                : Color.black.opacity(0.04),
                radius: kind == .primary ? 18 : 8,
                y: kind == .primary ? 10 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .primary:
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.purple.opacity(0.88)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

        case .secondary:
            Color.white.opacity(0.86)
        }
    }
}

