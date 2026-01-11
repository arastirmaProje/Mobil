//
//  ShiftLocationPickerSheet.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

struct ShiftLocationPickerSheet: View {

    @Environment(\.dismiss) private var dismiss

    let officeOptions: [ShiftStartOption]
    let onPick: (ShiftStartOption) -> Void

    @State private var selected: ShiftStartOption = .home

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Text(ConstantStrings.shiftLocationTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top, 24)

                Image("Some")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)

                locationRow

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 16)
            .presentationDetents([.large])
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onPick(selected)
                        dismiss()
                    } label: {
                        Text(ConstantStrings.start)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Row
    private var locationRow: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(ConstantStrings.locationLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Menu {
                Picker(ConstantStrings.locationLabel, selection: $selected) {
                    Text(ConstantStrings.homeLocation).tag(ShiftStartOption.home)

                    ForEach(officeOptions) { opt in
                        Text(opt.title).tag(opt)
                    }
                }
            } label: {
                HStack(spacing: 10) {

                    Text(ConstantStrings.locationLabel)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(selectedTitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.systemGray3))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .tint(.primary)
        }
    }

    private var selectedTitle: String {
        selected.title
    }
}
