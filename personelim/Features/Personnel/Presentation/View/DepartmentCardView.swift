import SwiftUI

struct DepartmentCardView: View {

    let department: DepartmentResponseDTO

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {

                Text(department.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)

                    Text("\(department.memberCount) \(ConstantStrings.memberCountSuffix)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
        .departmentBackground(name: department.name)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }
}
