//
//  OTPInputView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

struct OTPInputView: View {

    @Binding var code: String
    var onComplete: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor(for: index), lineWidth: 2)
                            .frame(width: 50, height: 55)

                        Text(charAt(index))
                            .font(.title2)
                    }
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
        .onTapGesture { isFocused = true }
        .onAppear { isFocused = true }
        .onChange(of: code) { value in
            if value.count == 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onComplete(value)
                }
            }
        }
    }

    private func charAt(_ index: Int) -> String {
        let chars = Array(code)
        return index < chars.count ? String(chars[index]) : ""
    }

    private func borderColor(for index: Int) -> Color {
        index == code.count ? Color.blue : Color.gray.opacity(0.25)
    }
}

// MARK: - Limit text helper
extension Binding where Value == String {
    func limit(_ length: Int) -> Binding<String> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = String($0.prefix(length)) }
        )
    }
}
