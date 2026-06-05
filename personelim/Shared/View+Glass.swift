import SwiftUI

extension View {

    // MARK: - BUTTON LEVEL GLASS (NEW)
    func glassBackground(cornerRadius: CGFloat = 14, intensity: CGFloat = 1) -> some View {
        self.background {
            ButtonGlassCard(cornerRadius: cornerRadius, intensity: intensity)
        }
    }
}

// MARK: - BUTTON GLASS COMPONENT
private struct ButtonGlassCard: View {

    let cornerRadius: CGFloat
    let intensity: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.10 * intensity))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.15 * intensity), lineWidth: 1)
            }
    }
}
