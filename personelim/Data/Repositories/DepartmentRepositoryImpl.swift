//
//  DepartmentRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

final class DepartmentRepositoryImpl: DepartmentRepositoryProtocol {
    
    private let network: NetworkManagerProtocol
    
    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }
    
    func fetchDepartments(businessId: String) async throws -> [DepartmentResponseDTO] {
        let response: ServiceResponse<[DepartmentResponseDTO]> = try await network.request(
            endpoint: .departments(businessId: businessId),
            method: .get,
            body: nil
        )
        return response.data ?? []
    }
    
    func createDepartment(request: CreateDepartmentRequestDTO) async throws {
        let _: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .createDepartment,
            method: .post,
            body: request
        )
    }
    
    func fetchCategories() async throws -> [JobCategoryDTO] {
        
        let response: [JobCategoryDTO] = try await network.request(
            endpoint: .jobCategories,
            method: .get,
            body: nil
        )
        return response
    }
    
    struct UpdateDepartmentRequest: Encodable {
        let name: String
        let categoryId: Int
    }

   

    func updateDepartment(id: String, name: String, categoryId: Int) async throws {
        let body = UpdateDepartmentRequest(name: name, categoryId: categoryId)
        
        let res: ServiceResponse<DepartmentResponseDTO> = try await network.request(
            endpoint: .updateDepartment(id: id),
            method: .put,
            body: body
        )
        
        guard res.success else {
            throw RepositoryError.api(message: res.message ?? "Güncelleme başarısız")
        }
    }

        func deleteDepartment(id: String) async throws {
            let res: ServiceResponse<Bool> = try await network.request(
                endpoint: .deleteDepartment(id: id), 
                method: .delete,
                body: nil
            )
            
            guard res.success else {
                throw RepositoryError.api(message: res.message ?? "Silme işlemi başarısız")
            }
        }
    
    func queryDepartmentPerformance(request: DepartmentPerformanceRequestDTO) async throws -> DepartmentPerformanceResponseDTO {
   
        let response: ServiceResponse<DepartmentPerformanceResponseDTO> = try await network.request(
            endpoint: .performanceQueryDepartment,
            method: .post,
            body: request
        )
        
     
        if response.success, let performanceData = response.data {
            return performanceData
        } else {
            throw RepositoryError.api(message: response.message ?? "Performans verisi alınamadı")
        }
    }
    func fetchDepartmentCharts(businessId: String, startDate: String, endDate: String) async throws -> BusinessDepartmentChartsResponseDTO {
            let requestDTO = DepartmentChartsRequestDTO(businessId: businessId, startDate: startDate, endDate: endDate)
            
          
            let response: ServiceResponse<BusinessDepartmentChartsResponseDTO> = try await network.request(
                endpoint: .queryDepartmentCharts,
                method: .post,
                body: requestDTO
            )
            
      
            if response.success, let chartsData = response.data {
                return chartsData
            } else {
                throw RepositoryError.api(message: response.message ?? "Grafik verileri alınamadı")
            }
        }
    }

