import Foundation

struct PerformanceBulkScoreItemDTO: Decodable, Identifiable {
    var id: String { (employeeUserId ?? calisanId ?? UUID().uuidString) }

    let employeeUserId: String?
    let calisanId: String?

    let performanceScore: Double?
    let performansSkoru: Double?

    let fullName: String?
    let adSoyad: String?

    var userId: String? { employeeUserId ?? calisanId }
    var score: Double? { performanceScore ?? performansSkoru }
    var name: String? { fullName ?? adSoyad }

    enum CodingKeys: String, CodingKey {
        case employeeUserId = "employeeUserId"
        case calisanId = "calisan_id"

        case performanceScore = "performanceScore"
        case performansSkoru = "performans_skoru"

        case fullName = "fullName"
        case adSoyad = "ad_soyad"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        employeeUserId = try c.decodeIfPresent(String.self, forKey: .employeeUserId)
        calisanId = try c.decodeIfPresent(String.self, forKey: .calisanId)

        if let d = try? c.decodeIfPresent(Double.self, forKey: .performanceScore) {
            performanceScore = d
        } else if let i = try? c.decodeIfPresent(Int.self, forKey: .performanceScore) {
            performanceScore = Double(i)
        } else {
            performanceScore = nil
        }

        if let d = try? c.decodeIfPresent(Double.self, forKey: .performansSkoru) {
            performansSkoru = d
        } else if let i = try? c.decodeIfPresent(Int.self, forKey: .performansSkoru) {
            performansSkoru = Double(i)
        } else {
            performansSkoru = nil
        }

        fullName = try c.decodeIfPresent(String.self, forKey: .fullName)
        adSoyad = try c.decodeIfPresent(String.self, forKey: .adSoyad)
    }
}
