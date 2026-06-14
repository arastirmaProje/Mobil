import SwiftUI

struct ChatFloatingButton: View {

    let onTap: () -> Void

    @GestureState private var isPressing = false
    @State private var sparklePhase = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isPressing ? 0.55 : 0.38),
                            Color.blue.opacity(isPressing ? 0.26 : 0.16),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .stroke(
                    Color.white.opacity(isPressing ? 0.95 : 0.55),
                    lineWidth: isPressing ? 1.8 : 1.1
                )

            Image(systemName: "sparkles")
                .font(.system(size: isPressing ? 22 : 25, weight: .bold))
                .foregroundStyle(.blue)
                .scaleEffect(sparklePhase ? 1.08 : 1.0)
                .opacity(sparklePhase ? 0.75 : 1.0)
        }
        .frame(width: 62, height: 62)
        .scaleEffect(isPressing ? 0.84 : 1.0)
        .shadow(
            color: .blue.opacity(isPressing ? 0.12 : 0.24),
            radius: isPressing ? 8 : 18,
            x: 0,
            y: isPressing ? 3 : 8
        )
        .animation(.spring(response: 0.22, dampingFraction: 0.62), value: isPressing)
        .animation(.easeInOut(duration: 0.65).repeatCount(4, autoreverses: true), value: sparklePhase)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressing) { _, state, _ in
                    state = true
                }
                .onEnded { _ in
                    onTap()
                }
        )
        .onAppear {
            sparklePhase = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                sparklePhase = false
            }
        }
    }
}
