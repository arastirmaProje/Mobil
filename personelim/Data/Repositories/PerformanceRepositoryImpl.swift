import Foundation

final class PerformanceRepositoryImpl: PerformanceRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func queryPerformance(_ body: PerformanceQueryRequestDTO) async throws -> PerformanceReportDTO {
        let res: ServiceResponse<PerformanceReportDTO> = try await network.request(
            endpoint: .performanceQuery,
            method: .post,
            body: body
        )

        guard let data = res.data else {
            throw RepositoryError.api( message: res.message ?? ConstantStrings.performanceReportCreateFail )
        }

        return data
    }

    func getReports(
        businessId: String,
        employeeUserId: String
    ) async throws -> [PerformanceReportDTO] {

        let res: ServiceResponse<[PerformanceReportDTO]> = try await network.request(
            endpoint: .performanceReports(
                businessId: businessId,
                employeeUserId: employeeUserId
            ),
            method: .get,
            body: nil
        )

        return res.data ?? []
    }

    func getReportDetail(
        reportId: String
    ) async throws -> PerformanceReportDTO {

        let res: ServiceResponse<PerformanceReportDTO> = try await network.request(
            endpoint: .performanceReportDetail(reportId: reportId),
            method: .get,
            body: nil
        )

        guard let data = res.data else {
            throw RepositoryError.api(
                message: res.message ?? ConstantStrings.performanceReportDetailFail
            )
        }

        return data
    }
    
    func bulkQueryScores(request: PerformanceBulkQueryRequestDTO) async throws -> ServiceResponse<PerformanceBulkScoreResponseDTO> {

        print("BULK QUERY START")
        print("businessId:", request.businessId)
        print("startDate:", request.startDate)
        print("endDate:", request.endDate)

        let res: ServiceResponse<PerformanceBulkScoreResponseDTO> =
            try await network.request(
                endpoint: .performanceQueryBulkScores,
                method: .post,
                body: request
            )

        print("BULK QUERY RESPONSE success:", res.success)
        print("BULK QUERY message:", res.message ?? .empty)

        if let data = res.data {
            print("BULK totalEmployees:", data.totalEmployees ?? -1)
            print("BULK scores count:", data.scores.count)

            for s in data.scores {
                print(
                    "   ➤ uid:",
                    s.userId ?? .empty,
                    "| score:",
                    s.score ?? -1
                )
            }
        } else {
            print("BULK RESPONSE DATA NIL")
        }

        print("BULK QUERY END")
        return res
    }
}
