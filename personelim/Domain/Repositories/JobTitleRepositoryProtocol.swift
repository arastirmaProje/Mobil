//
//  JobTitleRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

protocol JobTitleRepositoryProtocol {
    func getTitlesByDepartment(departmentId: String) async throws -> [JobTitleDTO]
}
