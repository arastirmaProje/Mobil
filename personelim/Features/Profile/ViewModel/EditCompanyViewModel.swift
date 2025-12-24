import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import CoreLocation

struct CompanyOfficeForm: Identifiable, Equatable {
    let id: UUID = UUID()
    var index: Int

    var name: String
    var latitude: Double?
    var longitude: Double?
}

@MainActor
final class EditCompanyViewModel: ObservableObject {

    @Published var companyName: String = ""
    @Published var companyEmail: String = ""
    @Published var phone: String = ""
    @Published var description: String = ""
    @Published var detailedAddress: String = ""
    @Published var photoItem: PhotosPickerItem?
    @Published var photoData: Data?
    @Published var documentURL: URL?

    @Published var provinces: [ProvinceDTO] = []
    @Published var districts: [DistrictDTO] = []
    @Published var selectedProvinceId: Int?
    @Published var selectedDistrictId: Int?

    @Published var offices: [CompanyOfficeForm] = [
        .init(index: 1, name: "", latitude: nil, longitude: nil)
    ]

    @Published var selectingOfficeUUID: UUID?
    @Published var showMapPicker: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let businessRepo: BusinessRepositoryProtocol
    private let locationRepo: LocationRepositoryProtocol
    private let authRepo: AuthRepositoryProtocol

    private(set) var businessId: String?

    init(
        authRepo: AuthRepositoryProtocol,
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager()),
        locationRepo: LocationRepositoryProtocol = LocationRepositoryImpl(network: NetworkManager())
    ) {
        self.authRepo = authRepo
        self.businessRepo = businessRepo
        self.locationRepo = locationRepo
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let me = try await authRepo.getProfile()
            companyEmail = me.email

            let businesses = try await businessRepo.getBusinesses()
            guard let b = businesses.first else {
                errorMessage = "Şirket bulunamadı."
                return
            }

            businessId = b.id
            companyName = b.name
            phone = b.phoneNumber ?? ""
            description = b.description ?? ""
            detailedAddress = b.address ?? ""

            selectedProvinceId = b.provinceId
            selectedDistrictId = b.districtId

            if let list = b.offices, !list.isEmpty {
                offices = list.enumerated().map { idx, o in
                    let n = (o.officeName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    return CompanyOfficeForm(
                        index: idx + 1,
                        name: n.isEmpty ? "Ofis \(idx + 1)" : n,
                        latitude: (o.latitude == 0 ? nil : o.latitude),
                        longitude: (o.longitude == 0 ? nil : o.longitude)
                    )
                }
            } else {
                offices = [.init(index: 1, name: "", latitude: nil, longitude: nil)]
            }

            provinces = try await locationRepo.getProvinces()
            if let pid = selectedProvinceId {
                districts = try await locationRepo.getDistricts(provinceId: pid)
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func onPickPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectProvince(_ id: Int) async {
        selectedProvinceId = id
        selectedDistrictId = nil
        districts = []
        do {
            districts = try await locationRepo.getDistricts(provinceId: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Office ops
    func addOffice() {
        let next = (offices.count) + 1
        offices.append(.init(index: next, name: "", latitude: nil, longitude: nil))
    }

    func removeLastOffice() {
        guard offices.count > 1 else { return }
        offices.removeLast()
        for i in offices.indices {
            offices[i].index = i + 1
        }
    }

    func beginPickLocation(for officeId: UUID) {
        selectingOfficeUUID = officeId
        showMapPicker = true
    }

    func setLocation(_ coordinate: CLLocationCoordinate2D) {
        guard let oid = selectingOfficeUUID,
              let i = offices.firstIndex(where: { $0.id == oid }) else { return }

        offices[i].latitude = coordinate.latitude
        offices[i].longitude = coordinate.longitude

        showMapPicker = false
        selectingOfficeUUID = nil
    }

    func setDocument(url: URL) {
        documentURL = url
    }

    // MARK: - Save
    func save() async throws {
        guard let businessId else {
            throw NSError(domain: "company", code: -1, userInfo: [NSLocalizedDescriptionKey: "businessId yok"])
        }

        isLoading = true
        defer { isLoading = false }

        let mainOffice = offices.first

        let req = UpdateBusinessRequestDTO(
            name: companyName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            address: detailedAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            locationName: mainOffice?.name.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: mainOffice?.latitude,
            longitude: mainOffice?.longitude,
            provinceId: selectedProvinceId,
            districtId: selectedDistrictId,
            imageData: photoData
        )

        _ = try await businessRepo.updateBusiness(businessId: businessId, request: req)
    }
}
 
