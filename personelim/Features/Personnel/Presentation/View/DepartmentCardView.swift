//
//  DepartmentCardView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import SwiftUI

struct DepartmentCardView: View {
    let department: DepartmentResponseDTO
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(department.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    
                    Text("\(department.memberCount) \(ConstantStrings.memberCountSuffix)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
