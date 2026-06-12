import Foundation
import CoreLocation

@MainActor
final class CreateCompanyViewModel: ObservableObject {

    // MARK: - VERIFY EMAIL

    @Published private(set) var verifyEmail: String = ""

    func setVerifyEmail(_ email: String) {
        self.verifyEmail = email
    }

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
        errorMessage = nil

        do {
            provinces = try await getProvincesUseCase.execute()
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.provinceLoadFailed
            )
        }
    }

    func selectProvince(_ provinceId: Int) async {
        selectedProvinceId = provinceId
        selectedDistrictId = nil
        districts = []
        errorMessage = nil

        do {
            districts = try await getDistrictsUseCase.execute(
                provinceId: provinceId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.districtLoadFailed
            )
        }
    }

    // MARK: - Office

    func addOffice() {
        let nextIndex = offices.count + 1

        offices.append(
            Office(
                index: nextIndex,
                name: String(
                    format: ConstantStrings.officeDefaultNameFormat,
                    nextIndex
                ),
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

    func setLocation(
        _ coord: CLLocationCoordinate2D,
        address: String?
    ) {
        guard let id = selectingOfficeId,
              let idx = offices.firstIndex(where: { $0.id == id }) else {
            return
        }

        offices[idx].latitude = coord.latitude
        offices[idx].longitude = coord.longitude

        if let address,
           !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            offices[idx].address = address
        }

        selectingOfficeId = nil
    }

    // MARK: - Create Business

    func createCompany(appState: AppState) async {
        let name = companyName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            errorMessage = ConstantStrings.companyNameRequired
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let request = CreateBusinessRequestDTO(
            businessName: name,
            phoneNumber: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            provinceId: selectedProvinceId ?? 1,
            districtId: selectedDistrictId ?? 1,
            address: detailedAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            offices: offices.map {
                OfficeLocationDTO(
                    officeName: $0.name,
                    latitude: $0.latitude ?? 0,
                    longitude: $0.longitude ?? 0
                )
            }
        )

        do {
            _ = try await createBusinessAndGetIdUseCase.execute(
                request: request
            )

            showOTP = true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.businessCreateFail
            )
        }
    }

    // MARK: - Verify Business

    func verifyBusiness(code: String) async throws {
        let success = try await verifyBusinessUseCase.execute(code: code)

        if !success {
            throw RepositoryError.api(
                message: ConstantStrings.businessVerifyFailed
            )
        }
    }

    // MARK: - Helpers

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
