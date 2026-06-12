import Foundation
import SwiftUI

@MainActor
class DepartmentViewModel: ObservableObject {

    @Published var departments: [DepartmentResponseDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var categories: [JobCategoryDTO] = []

    @Published var departmentPerformance: DepartmentPerformanceResponseDTO?
    @Published var isPerformanceLoading = false

    @Published var chartData: [DepartmentChartItemDTO] = []
    @Published var isChartsLoading = false
    @Published var businessCharts: BusinessDepartmentChartsResponseDTO?

    private let repository: DepartmentRepositoryProtocol

    init(
        repository: DepartmentRepositoryProtocol = DepartmentRepositoryImpl()
    ) {
        self.repository = repository
    }

    func fetchDepartments(businessId: String) async {
        guard !businessId.isEmpty else {
            errorMessage = ConstantStrings.businessInfoNotFoundError
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            departments = try await repository.fetchDepartments(
                businessId: businessId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentFetchError
            )
        }
    }

    func fetchCategories() async {
        guard categories.isEmpty else { return }

        do {
            categories = try await repository.fetchCategories()
        } catch {
            print("\(ConstantStrings.categoryFetchError): \(error)")
        }
    }

    func createDepartment(
        name: String,
        businessId: String,
        categoryId: Int
    ) async {
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            errorMessage = ConstantStrings.departmentNameEmptyError
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        let request = CreateDepartmentRequestDTO(
            name: trimmedName,
            businessId: businessId,
            categoryId: categoryId
        )

        do {
            try await repository.createDepartment(request: request)
            departments = try await repository.fetchDepartments(
                businessId: businessId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentCreateFailed
            )
        }
    }

    func updateDepartment(
        id: String,
        name: String,
        categoryId: Int,
        businessId: String
    ) async {
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        do {
            try await repository.updateDepartment(
                id: id,
                name: trimmedName,
                categoryId: categoryId
            )

            departments = try await repository.fetchDepartments(
                businessId: businessId
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentUpdateFailed
            )
        }
    }

    func deleteDepartment(
        id: String,
        businessId: String
    ) async {
        do {
            try await repository.deleteDepartment(id: id)

            departments = try await repository.fetchDepartments(
                businessId: businessId
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentDeleteFailed
            )
        }
    }

    func fetchDepartmentPerformance(
        businessId: String,
        departmentId: String,
        startDate: Date,
        endDate: Date
    ) async {
        isPerformanceLoading = true
        errorMessage = nil

        defer {
            isPerformanceLoading = false
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        let request = DepartmentPerformanceRequestDTO(
            businessId: businessId,
            departmentId: departmentId,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate)
        )

        do {
            departmentPerformance = try await repository
                .queryDepartmentPerformance(request: request)
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentPerformanceLoadFailed
            )
        }
    }

    func fetchDepartmentCharts(
        businessId: String,
        startDate: Date,
        endDate: Date
    ) async {
        guard !businessId.isEmpty else { return }

        isChartsLoading = true
        errorMessage = nil

        defer {
            isChartsLoading = false
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)

        do {
            businessCharts = try await repository.fetchDepartmentCharts(
                businessId: businessId,
                startDate: startStr,
                endDate: endStr
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentChartsLoadFailed
            )
            print("Grafik Fetch Hatası:", error)
        }
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
