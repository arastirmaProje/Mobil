//
//  DepartmentRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

protocol DepartmentRepositoryProtocol {
    func fetchDepartments(businessId: String) async throws -> [DepartmentResponseDTO]
    func createDepartment(request: CreateDepartmentRequestDTO) async throws
    func fetchCategories() async throws -> [JobCategoryDTO]
    func updateDepartment(id: String, name: String, categoryId: Int) async throws
        func deleteDepartment(id: String) async throws
}
