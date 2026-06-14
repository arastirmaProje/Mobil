//
//  ChatFloatingButton.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import SwiftUI

struct ChatFloatingButton: View {

    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 62, height: 62)
                    .shadow(color: .blue.opacity(0.35), radius: 16, x: 0, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
