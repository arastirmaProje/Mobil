//
//  BusinessMemberViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

@MainActor
class BusinessMemberViewModel: ObservableObject {
    @Published var members: [BusinessMemberDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: BusinessMemberRepositoryProtocol
    
    init(repository: BusinessMemberRepositoryProtocol = BusinessMemberRepositoryImpl(network: NetworkManager.shared)) {
        self.repository = repository
    }
    
    func fetchMembers(businessId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.members = try await repository.getMembers(businessId: businessId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func addMember(request: CreateMemberRequestDTO) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await repository.addMember(request: request)
            await fetchMembers(businessId: request.businessId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
