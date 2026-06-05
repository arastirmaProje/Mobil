import SwiftUI

struct OTPInputView: View {

    @Binding var code: String
    let onComplete: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    otpBox(index)
                }
            }

            TextField("", text: $code.limit(6))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .focused($isFocused)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: code) { _, value in
            if value.count == 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onComplete(value)
                }
            }
        }
    }

    // MARK: - Box

    private func otpBox(_ index: Int) -> some View {

        let isCurrent = code.count == index
        let hasValue = index < code.count

        return ZStack {

            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(Color(.systemBackground))

            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(
                isCurrent
                ? Color.blue
                : Color.black.opacity(0.08),
                lineWidth: isCurrent ? 2 : 1
            )

            if hasValue {
                Text(character(at: index))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 52, height: 62)
        .scaleEffect(hasValue ? 1 : 0.97)
        .shadow(
            color: isCurrent
            ? Color.blue.opacity(0.18)
            : .clear,
            radius: 10
        )
        .animation(
            .spring(response: 0.25, dampingFraction: 0.8),
            value: code
        )
    }

    // MARK: - Helpers

    private func character(at index: Int) -> String {
        let chars = Array(code)
        return index < chars.count
        ? String(chars[index])
        : ""
    }
}

// MARK: - Limit Helper

extension Binding where Value == String {

    func limit(_ length: Int) -> Binding<String> {
        Binding(
            get: {
                wrappedValue
            },
            set: {
                wrappedValue = String($0.prefix(length))
            }
        )
    }
}
