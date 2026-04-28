//
//  JobTitleCategoryResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

struct JobTitleCategoryResponseDTO: Codable {
    let categoryId: Int
    let categoryName: String
    let titles: [JobTitleDTO] 
}
