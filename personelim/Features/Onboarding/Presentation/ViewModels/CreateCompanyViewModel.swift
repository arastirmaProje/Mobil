//
//  CreateCompanyViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import Foundation
import CoreLocation

@MainActor
final class CreateCompanyViewModel: ObservableObject {

    // MARK: - VERIFY EMAIL
    @Published private(set) var verifyEmail: String = ""
    func setVerifyEmail(_ email: String) { self.verifyEmail = email }

    // MARK: - Inputs
    @Published var companyName = ""
    @Published var selectedProvinceId: Int? = nil
    @Published var selectedDistrictId: Int? = nil

    @Published var provinces: [ProvinceDTO] = []
    @Published var districts: [DistrictDTO] = []
    @Published var detailedAddress = ""
    @Published var phone = ""
    @Published var description = ""
    @Published var offices: [Office] = []
    @Published var showMapPicker = false
    @Published var selectingOfficeId: UUID? = nil
    @Published var isLoading = false
    @Published var showOTP = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let createBusinessUseCase: CreateBusinessUseCaseProtocol
    private let verifyBusinessUseCase: VerifyBusinessUseCaseProtocol
    private let createBusinessAndGetIdUseCase: CreateBusinessAndGetIdUseCaseProtocol
    private let getProvincesUseCase: GetProvincesUseCaseProtocol
    private let getDistrictsUseCase: GetDistrictsUseCaseProtocol

    init(
        createBusinessUseCase: CreateBusinessUseCaseProtocol = CreateBusinessUseCase(),
        verifyBusinessUseCase: VerifyBusinessUseCaseProtocol = VerifyBusinessUseCase(),
        createBusinessAndGetIdUseCase: CreateBusinessAndGetIdUseCaseProtocol = CreateBusinessAndGetIdUseCase(),
        getProvincesUseCase: GetProvincesUseCaseProtocol = GetProvincesUseCase(),
        getDistrictsUseCase: GetDistrictsUseCaseProtocol = GetDistrictsUseCase()
    ) {
        self.createBusinessUseCase = createBusinessUseCase
        self.verifyBusinessUseCase = verifyBusinessUseCase
        self.createBusinessAndGetIdUseCase = createBusinessAndGetIdUseCase
        self.getProvincesUseCase = getProvincesUseCase
        self.getDistrictsUseCase = getDistrictsUseCase
    }

    // MARK: - Loaders
    func loadProvinces() async {
        print("DEBUG: loadProvinces çağırdım") // 1. Kontrol
        do {
            let result = try await getProvincesUseCase.execute()
            print("DEBUG: Başarılı ve  il sayısı: \(result.count)") // 2. Kontrol
            self.provinces = result
        } catch {
            print("DEBUG: İL YÜKLEME HATASI: \(error)") // 3. Kontrol
            self.errorMessage = "İller yüklenemedi: \(error.localizedDescription)"
        }
    }

    func selectProvince(_ provinceId: Int) async {
        selectedProvinceId = provinceId
        selectedDistrictId = nil
        districts = []
        do { districts = try await getDistrictsUseCase.execute(provinceId: provinceId) }
        catch { errorMessage = error.localizedDescription }
    }

    // MARK: - Office
    func addOffice() {
        let nextIndex = offices.count + 1
        offices.append(
            Office(
                index: nextIndex,
                name: "Ofis \(nextIndex)",
                address: "",
                latitude: nil,
                longitude: nil
            )
        )
    }

    func removeLastOffice() {
        guard !offices.isEmpty else { return }
        offices.removeLast()
    }

    // MARK: - Map Picker Bridge
    func beginPickLocation(for officeId: UUID) {
        selectingOfficeId = officeId
        showMapPicker = true
    }

    func setLocation(_ coord: CLLocationCoordinate2D, address: String?) {
        guard let id = selectingOfficeId,
              let idx = offices.firstIndex(where: { $0.id == id }) else { return }

        offices[idx].latitude = coord.latitude
        offices[idx].longitude = coord.longitude

        if let address, !address.isEmpty {
            offices[idx].address = address
        }

        selectingOfficeId = nil
    }

    // MARK: - Create Business
    func createCompany(appState: AppState) async {

       // let isFormValid =
       //     !companyName.isEmpty &&
       //     selectedProvinceId != nil &&     burası boş geldiği için böyle yaptım şimdilik zorunlu olmasın bakalım.
       //     selectedDistrictId != nil
        let isFormValid = !companyName.isEmpty 

        guard isFormValid else {
            errorMessage = "Şirket adı, il ve ilçe zorunludur."
            return
        }

        isLoading = true
        errorMessage = nil

        let request = CreateBusinessRequestDTO(
            businessName: companyName,
            phoneNumber: phone,
            provinceId: selectedProvinceId ?? 1, // Seçilmediyse zorla 1 gönder
                districtId: selectedDistrictId ?? 1, // Seçilmediyse zorla 1 gönder
           // provinceId: selectedProvinceId ?? 0,
           // districtId: selectedDistrictId ?? 0,
            address: detailedAddress,
            description: description,
            offices: offices.map {
                OfficeLocationDTO(
                    officeName: $0.name,
                    latitude: $0.latitude ?? 0,
                    longitude: $0.longitude ?? 0
                )
            }
        )

        do {
            let businessId = try await createBusinessAndGetIdUseCase.execute(request: request)
            showOTP = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Verify Business
    func verifyBusiness(code: String) async throws {
        let success = try await verifyBusinessUseCase.execute(code: code)
        if !success { throw NSError(domain: "VERIFY_FAILED", code: -1) }
    }
}
