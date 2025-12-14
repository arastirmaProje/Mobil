//
//  CreateCompanyViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import Foundation

@MainActor
final class CreateCompanyViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var companyName = ""
    @Published var selectedCity = ""
    @Published var selectedDistrict = ""
    @Published var detailedAddress = ""
    @Published var phone = ""
    @Published var description = ""
    @Published var offices: [Office] = []

    // MARK: - UI State
    @Published var isLoading = false
    @Published var showOTP = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let createBusinessUseCase: CreateBusinessUseCaseProtocol
    private let verifyBusinessUseCase: VerifyBusinessUseCaseProtocol

    init(
        createBusinessUseCase: CreateBusinessUseCaseProtocol = CreateBusinessUseCase(),
        verifyBusinessUseCase: VerifyBusinessUseCaseProtocol = VerifyBusinessUseCase()
    ) {
        self.createBusinessUseCase = createBusinessUseCase
        self.verifyBusinessUseCase = verifyBusinessUseCase
    }

    // MARK: - Mock Location Data (şimdilik)
    let cities = ["İstanbul", "Ankara", "İzmir"]

    let districts: [String: [String]] = [
        "İstanbul": ["Kadıköy", "Üsküdar", "Beşiktaş"],
        "Ankara": ["Çankaya", "Keçiören"],
        "İzmir": ["Bornova", "Konak"]
    ]

    // MARK: - Computed
    var showDistricts: Bool {
        !selectedCity.isEmpty
    }

    var isFormValid: Bool {
        !companyName.isEmpty &&
        !selectedCity.isEmpty &&
        !selectedDistrict.isEmpty
    }

    // MARK: - Office
    func addOffice() {
        offices.append(
            Office(index: offices.count + 1, address: "")
        )
    }

    func removeLastOffice() {
        guard !offices.isEmpty else { return }
        offices.removeLast()
    }

    // MARK: - STEP 1: Create Business
    func createCompany() async {
        guard isFormValid else {
            errorMessage = "Lütfen zorunlu alanları doldurun."
            return
        }

        isLoading = true

        let request = CreateBusinessRequestDTO(
            businessName: companyName,
            phoneNumber: phone,
            provinceId: 1,
            districtId: 1,
            address: detailedAddress,
            description: description,
            offices: offices.map {
                OfficeLocationDTO(
                    officeName: "Ofis \($0.index)",
                    latitude: 0,
                    longitude: 0
                )
            }
        )

        do {
            try await createBusinessUseCase.execute(request: request)
            showOTP = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - STEP 2: Verify Business
    func verifyBusiness(code: String) async -> Bool {
        do {
            try await verifyBusinessUseCase.execute(code: code)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
