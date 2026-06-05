import SwiftUI

struct LeaveSectionView: View {

    let remainingDaysText: String
    let onCreateLeave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            contentCard
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("İzinler")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)

                Text("İzin durumunu ve kullanımını yönet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onCreateLeave) {
                Label("İzin kullan", systemImage: "calendar.badge.plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Content

    private var contentCard: some View {
        HStack(spacing: 14) {
            iconBox

            VStack(alignment: .leading, spacing: 5) {
                Text("Kalan / kullanılan izin")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(remainingDaysText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("Güncel izin özeti")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.8))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.025), radius: 8, y: 4)
    }

    private var iconBox: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Image(systemName: "calendar")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.blue)
        }
        .frame(width: 48, height: 48)
    }
}
