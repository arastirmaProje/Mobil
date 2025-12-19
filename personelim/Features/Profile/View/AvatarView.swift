//
//  AvatarView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 17.12.2025.
//

import SwiftUI

struct AvatarView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            case .failure(_):
                Color.gray.opacity(0.3)
            default:
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
