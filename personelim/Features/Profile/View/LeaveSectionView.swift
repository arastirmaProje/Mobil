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
        VStack(alignment: .leading, spacing: 10) {

            // MARK: - Header (Sorgu ile aynı hizalama)
            HStack {
                Text("İzinler")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button(action: onCreateLeave) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("İzin kullan")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)

            // MARK: - Card (sadece veri yüzeyi)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kullanılan izin")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(remainingDaysText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
}
