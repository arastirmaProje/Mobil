import Foundation

struct PerformanceReportDTO: Decodable, Identifiable {
    var id: String { reportId ?? employeeId ?? UUID().uuidString }

    let reportId: String?
    let businessId: String?
    let employeeUserId: String?

    let createdByName: String?
    let startDate: String?
    let endDate: String?
    let score: Int?
    let summaryText: String?
    let detailText: String?
    let employeeId: String?

    init(from decoder: Decoder) throws {

        let c1 = try decoder.container(keyedBy: CodingKeys.self)

        let reportId = try c1.decodeIfPresent(String.self, forKey: .reportId)
        let businessId = try c1.decodeIfPresent(String.self, forKey: .businessId)
        let employeeUserId = try c1.decodeIfPresent(String.self, forKey: .employeeUserId)

        let createdByName = try c1.decodeIfPresent(String.self, forKey: .createdByName)
        let startDate = try c1.decodeIfPresent(String.self, forKey: .startDate)
        let endDate = try c1.decodeIfPresent(String.self, forKey: .endDate)

        let scoreCamel = try c1.decodeIfPresent(Int.self, forKey: .score)
        let summaryCamel = try c1.decodeIfPresent(String.self, forKey: .summaryText)
        let detailCamel = try c1.decodeIfPresent(String.self, forKey: .detailText)
        let c2 = try decoder.container(keyedBy: BackendKeys.self)

        let employeeId = try c2.decodeIfPresent(String.self, forKey: .employeeId)
        let scoreBackendInt = try c2.decodeIntLossyIfPresent(forKey: .backendScore)

        let summaryBackend = try c2.decodeIfPresent(String.self, forKey: .backendSummary)
        let detailBackend = try c2.decodeIfPresent(String.self, forKey: .backendDetail)
        let c3 = try? decoder.container(keyedBy: ListKeys.self)

        let listStart = try c3?.decodeIfPresent(String.self, forKey: .periodStart)
        let listEnd = try c3?.decodeIfPresent(String.self, forKey: .periodEnd)
        let listScoreInt = try c3?.decodeIntLossyIfPresent(forKey: .performanceScore)
        self.reportId = reportId
        self.businessId = businessId
        self.employeeUserId = employeeUserId

        self.createdByName = createdByName

        self.startDate = startDate ?? listStart
        self.endDate = endDate ?? listEnd

        self.employeeId = employeeId
        self.score = scoreCamel ?? scoreBackendInt ?? listScoreInt

        self.summaryText = summaryCamel ?? summaryBackend
        self.detailText = detailCamel ?? detailBackend
    }

    private enum CodingKeys: String, CodingKey {
        case reportId = "id"
        case businessId
        case employeeUserId
        case createdByName
        case startDate
        case endDate
        case score
        case summaryText
        case detailText
    }

    private enum BackendKeys: String, CodingKey {
        case employeeId = "calisan_id"
        case backendScore = "performans_skoru"
        case backendSummary = "rapor_ozeti"
        case backendDetail = "detayli_rapor"
    }

    private enum ListKeys: String, CodingKey {
        case periodStart
        case periodEnd
        case performanceScore
        case createdAt
    }
}

// MARK: - Lossy decode helpers (Double / Int / String -> Int)
private extension KeyedDecodingContainer {

    func decodeIntLossyIfPresent(forKey key: Key) throws -> Int? {
        if let i = try? decodeIfPresent(Int.self, forKey: key) {
            return i
        }
        if let d = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(d.rounded())
        }
        if let s = try? decodeIfPresent(String.self, forKey: key) {
            let normalized = s.replacingOccurrences(of: ",", with: ".")
            if let d = Double(normalized) {
                return Int(d.rounded())
            }
        }
        return nil
    }
}
