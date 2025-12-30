//
//  LeaveSectionView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import SwiftUI

struct LeaveSectionView: View {

    let remainingDaysText: String
    let onCreateLeave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("İzinler")
                .font(.system(size: 16, weight: .semibold))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kullanılan izin")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text(remainingDaysText)
                        .font(.system(size: 18, weight: .semibold))
                }

                Spacer()

                Button(action: onCreateLeave) {
                    Text("İzin kullan")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                        )
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
