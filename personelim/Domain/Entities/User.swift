//
//  User.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

struct User: Identifiable {
    let id: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var imageUrl: String?
}
