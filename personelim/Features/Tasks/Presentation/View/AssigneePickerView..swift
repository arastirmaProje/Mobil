//
//  AssigneePickerView..swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.12.2025.
//

import SwiftUI

struct AssigneePickerView: View {

    @Environment(\.dismiss) private var dismiss
    let members: [BusinessMemberDTO]
    let onSelect: (BusinessMemberDTO) -> Void

    var body: some View {
        Group {
            if members.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("Çalışan bulunamadı")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(members, id: \.id) { member in
                        Button {
                            onSelect(member)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.fullName)
                                        .font(.body)

                                    Text(member.position ?? "-")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "checkmark")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Çalışan Seç")
    }
}
