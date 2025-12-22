//
//  UpdateTaskStatusRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.12.2025.
//

import Foundation

struct UpdateTaskStatusRequestDTO: Encodable {
    let status: String
    let thoughts: String
    let difficulty: String
}
