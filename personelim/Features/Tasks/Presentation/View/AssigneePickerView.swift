import SwiftUI

struct AssigneePickerView: View {

    let members: [BusinessMemberDTO]
    @Binding var selectedAssignees: Set<String>
    let onDone: () -> Void

    var body: some View {
        List {
            ForEach(members, id: \.userId) { member in
                row(member)
            }
        }
        .navigationTitle("Çalışan Seç")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Bitti") {
                    onDone()
                }
            }
        }
    }

    // MARK: - Row
    @ViewBuilder
    private func row(_ member: BusinessMemberDTO) -> some View {
        Button {
            toggle(member.userId)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.fullName)
                    Text(member.position ?? "-")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected(member.userId)
                      ? "checkmark.circle.fill"
                      : "circle")
                .foregroundColor(isSelected(member.userId) ? .blue : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers
    private func isSelected(_ id: String) -> Bool {
        selectedAssignees.contains(id)
    }

    private func toggle(_ id: String) {
        if selectedAssignees.contains(id) {
            selectedAssignees.remove(id)
        } else {
            selectedAssignees.insert(id)
        }
    }
}
