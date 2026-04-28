//
//  JobTitleViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

@MainActor
class JobTitleViewModel: ObservableObject {
    @Published var jobTitles: [JobTitleDTO] = []
    @Published var isLoading = false
    
    private let repository: JobTitleRepositoryProtocol

    init(repository: JobTitleRepositoryProtocol = JobTitleRepositoryImpl(network: NetworkManager.shared)) {
        self.repository = repository
    }

    func fetchJobTitlesByDepartment(departmentId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let titles = try await repository.getTitlesByDepartment(departmentId: departmentId)
            self.jobTitles = titles
        } catch {
            print("\(ConstantStrings.jobTitlesFetchError): \(error)")
        }
    }
}
