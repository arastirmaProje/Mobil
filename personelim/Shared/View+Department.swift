//
//  View+Department.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 3.06.2026.
//

import SwiftUI

extension View {

    func departmentBackground(name: String, cornerRadius: CGFloat = 18, opacity: Double = 0.12) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    DepartmentColorService.color(for: name)
                        .opacity(opacity)
                )
        )
    }
}
