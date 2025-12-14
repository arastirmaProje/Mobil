//
//  Untitled.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import SwiftUI

enum Typography {
    
    // MARK: - H1
    enum H1 {
        static let semibold: Font = .system(size: 24, weight: .semibold)
        static let regular: Font = .system(size: 24, weight: .regular)
    }
    
    // MARK: - H2
    enum H2 {
        static let semibold: Font = .system(size: 20, weight: .semibold)
    }
    
    // MARK: - H3
    enum H3 {
        static let semibold: Font = .system(size: 18, weight: .semibold)
    }
    
    // MARK: - H4
    enum H4 {
        static let regular: Font = .system(size: 16, weight: .regular)
        static let semibold: Font = .system(size: 16, weight: .semibold)
    }
    
    // MARK: - H5
    enum H5 {
        static let regular: Font = .system(size: 14, weight: .regular)
        static let semibold: Font = .system(size: 14, weight: .semibold)
    }
    
    // MARK: - H6
    enum H6 {
        static let regular: Font = .system(size: 12, weight: .regular)
    }
    
    // MARK: - H7
    enum H7 {
        static let regular: Font = .system(size: 10, weight: .regular)
    }
}
