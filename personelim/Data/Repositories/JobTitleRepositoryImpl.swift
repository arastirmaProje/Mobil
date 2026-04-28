//
//  JobTitleRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

final class JobTitleRepositoryImpl: JobTitleRepositoryProtocol {
    
    private let network: NetworkManagerProtocol
    
    init(network: NetworkManagerProtocol) {
        self.network = network
    }
    
    func getTitlesByDepartment(departmentId: String) async throws -> [JobTitleDTO] {
        let res: JobTitleCategoryResponseDTO = try await network.request(
            endpoint: .jobTitlesByDepartment(departmentId: departmentId),
            method: .get,
            body: nil
        )
        
        return res.titles
    }
}
