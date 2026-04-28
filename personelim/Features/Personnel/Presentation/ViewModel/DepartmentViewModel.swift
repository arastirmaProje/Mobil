import Foundation
import SwiftUI

@MainActor
class DepartmentViewModel: ObservableObject {
    @Published var departments: [DepartmentResponseDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var categories: [JobCategoryDTO] = []
    
    private let repository: DepartmentRepositoryProtocol
    
    init(repository: DepartmentRepositoryProtocol = DepartmentRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchDepartments(businessId: String) async {
        guard !businessId.isEmpty else {
            self.errorMessage = ConstantStrings.businessInfoNotFoundError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            self.departments = try await repository.fetchDepartments(businessId: businessId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchCategories() async {
        guard categories.isEmpty else { return }
        
        do {
            let fetchedCategories = try await repository.fetchCategories()
            self.categories = fetchedCategories
        } catch {
            print("\(ConstantStrings.categoryFetchError): \(error)")
        }
    }
    
    func createDepartment(name: String, businessId: String, categoryId: Int) async {
        guard !name.isEmpty else {
            self.errorMessage = ConstantStrings.departmentNameEmptyError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = CreateDepartmentRequestDTO(
            name: name,
            businessId: businessId,
            categoryId: categoryId
        )
        
        do {
            try await repository.createDepartment(request: request)
            await fetchDepartments(businessId: businessId)
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func updateDepartment(id: String, name: String, categoryId: Int, businessId: String) async {
        do {
            try await repository.updateDepartment(id: id, name: name, categoryId: categoryId)
            await fetchDepartments(businessId: businessId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteDepartment(id: String, businessId: String) async {
        do {
            try await repository.deleteDepartment(id: id)
            await fetchDepartments(businessId: businessId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
