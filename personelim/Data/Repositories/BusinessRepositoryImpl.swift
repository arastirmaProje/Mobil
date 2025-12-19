//
//  BusinessRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

final class BusinessRepositoryImpl: BusinessRepositoryProtocol {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func createBusiness(request: CreateBusinessRequestDTO) async throws {
        _ = try await createBusinessAndReturnId(request: request)
    }
    
    func createBusinessAndReturnId(request: CreateBusinessRequestDTO) async throws -> String {
        
        let response: CreateBusinessServiceResponseDTO = try await networkManager.request(
            endpoint: .createBusiness,
            method: .post,
            body: request
        )
        
        guard response.success, let id = response.data?.id else {
            throw RepositoryError.api(message: response.message ?? "Şirket oluşturulamadı")
        }
        
        return id
    }
    
    func verifyBusiness(code: String) async throws -> VerifyBusinessResponseDTO {
        let body = VerifyBusinessRequestDTO(code: code)
        
        let response: VerifyBusinessResponseDTO = try await networkManager.request(
            endpoint: .verifyBusiness,
            method: .post,
            body: body
        )
        return response
    }
    
    func getBusiness(businessId: String) async throws -> BusinessDTO {
        
        let response: BusinessServiceResponseDTO = try await networkManager.request(
            endpoint: .getBusiness(businessId: businessId),
            method: .get,
            body: nil
        )
        
        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? "Şirket bilgisi alınamadı")
        }
        
        return data
    }
    
        func getBusinesses() async throws -> [BusinessDTO] {
            let response: ServiceResponse<[BusinessDTO]> = try await networkManager.request(
                endpoint: .businessList,
                method: .get,
                body: nil
            )

            guard response.success, let data = response.data else {
                throw RepositoryError.api(message: response.message ?? "Şirketler alınamadı")
            }

            return data
        }

        func getMyBusiness() async throws -> BusinessDTO {
            let list = try await getBusinesses()

            guard let first = list.first else {
                throw RepositoryError.api(message: "Şirket bulunamadı")
            }

            return first
        }
    
    func updateBusiness(businessId: String, request: UpdateBusinessRequestDTO) async throws -> EmptyResponse {

        var fields: [String: String] = [:]

        if let v = request.name, !v.isEmpty { fields["Name"] = v }
        if let v = request.description, !v.isEmpty { fields["Description"] = v }
        if let v = request.address, !v.isEmpty { fields["Address"] = v }
        if let v = request.phoneNumber, !v.isEmpty { fields["PhoneNumber"] = v }
        if let v = request.locationName, !v.isEmpty { fields["LocationName"] = v }

        if let v = request.latitude { fields["Latitude"] = String(v) }
        if let v = request.longitude { fields["Longitude"] = String(v) }

        if let v = request.provinceId { fields["ProvinceId"] = String(v) }
        if let v = request.districtId { fields["DistrictId"] = String(v) }

        var files: [MultipartFile] = []
        if let img = request.imageData {
            files.append(
                MultipartFile(
                    fieldName: "Image",       
                    fileName: "company.jpg",
                    mimeType: "image/jpeg",
                    data: img
                )
            )
        }

        let resp: EmptyResponse = try await networkManager.uploadMultipart(
            endpoint: .updateBusiness(businessId: businessId),
            method: .put,
            fields: fields,
            files: files
        )

        return resp
    }




}
