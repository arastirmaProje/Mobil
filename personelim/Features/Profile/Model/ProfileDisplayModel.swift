import Foundation

struct DocumentToPreview: Identifiable {
    let id: String
    let title: String
    let documentId: String
}

struct OfficeUI: Identifiable {
    let id: String
    let name: String
    let latitude: Double?
    let longitude: Double?

    var hasCoordinate: Bool {
        latitude != nil && longitude != nil
    }
}

struct EmployeeProfileUI {
    let fullName: String
    let position: String?
    let salaryText: String?
    let tcIdentityNumber: String?
    let email: String
    let imageUrl: String?
    let cvFiles: [BusinessMemberDocumentDTO]
    let documentFiles: [BusinessMemberDocumentDTO]
    let remainingLeaveDaysText: String
}

struct ManagerProfileUI {
    let companyName: String
    let companyDescription: String?
    let companyEmail: String
    let offices: [OfficeUI]
    let companyImageUrl: String?
    let employee: EmployeeProfileUI

    let companyPhoneNumber: String?
    let companyAddress: String?
    let companyProvinceName: String?
    let companyDistrictName: String?
    let companyLocationName: String? 

    var companyCityLine: String {
        let p = (companyProvinceName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let d = (companyDistrictName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if !p.isEmpty && !d.isEmpty { return "\(p) / \(d)" }
        if !p.isEmpty { return p }
        if !d.isEmpty { return d }
        return "-"
    }
}
