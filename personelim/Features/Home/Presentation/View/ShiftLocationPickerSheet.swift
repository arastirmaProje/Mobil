import SwiftUI

struct ShiftLocationPickerSheet: View {

    @Environment(\.dismiss) private var dismiss

    let officeOptions: [ShiftStartOption]
    let onPick: (ShiftStartOption) -> Void

    @State private var selected: ShiftStartOption = .home
    @State private var animateIcon = false

    private var allOptions: [ShiftStartOption] {
        [.home] + officeOptions
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {

                        heroIcon

                        headerText

                        locationCard

                        Spacer(minLength: 140)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 32)
                }

                bottomStartButton
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.15)
                    .repeatForever(autoreverses: true)
                ) {
                    animateIcon = true
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Hero

    private var heroIcon: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 118, height: 118)
                .scaleEffect(animateIcon ? 1.06 : 0.96)

            Circle()
                .stroke(Color.blue.opacity(0.14), lineWidth: 1)
                .frame(width: 132, height: 132)
                .scaleEffect(animateIcon ? 1.02 : 0.96)

            Image(systemName: selectedIcon)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.blue)
                .scaleEffect(animateIcon ? 1.04 : 1)
        }
        .padding(.top, 4)
    }

    private var headerText: some View {
        VStack(spacing: 6) {
            Text(ConstantStrings.shiftLocationTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            Text(ConstantStrings.shiftLocationDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var selectedIcon: String {
        switch selected {
        case .home:
            return "house.fill"
        default:
            return "building.2.fill"
        }
    }

    // MARK: - Location Card

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.locationLabel)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(String(format: ConstantStrings.selectedLocationFormat, selectedTitle))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "location.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 0) {
                ForEach(allOptions) { option in
                    locationOptionRow(option)

                    if option.id != allOptions.last?.id {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )

            if officeOptions.isEmpty {
                Text(ConstantStrings.noOfficeHomeHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func locationOptionRow(_ option: ShiftStartOption) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selected = option
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: optionIcon(option))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selected == option ? .blue : .secondary)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(selected == option ? Color.blue.opacity(0.10) : Color(.systemGray6))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(option == .home ? ConstantStrings.workFromHomeSubtitle : ConstantStrings.officeLocationSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if selected == option {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.blue)
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.12), lineWidth: 1.3)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                selected == option
                ? Color.blue.opacity(0.035)
                : Color(.systemBackground)
            )
        }
        .buttonStyle(.plain)
    }

    private func optionIcon(_ option: ShiftStartOption) -> String {
        switch option {
        case .home:
            return "house.fill"
        default:
            return "building.2.fill"
        }
    }

    // MARK: - Bottom Button

    private var bottomStartButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                onPick(selected)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")

                    Text(ConstantStrings.start)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(.regularMaterial)
        }
    }

    private var selectedTitle: String {
        selected.title
    }
}
