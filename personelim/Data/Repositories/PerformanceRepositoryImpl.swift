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
            throw NSError(
                domain: "performance",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: res.message ?? "Rapor oluşturulamadı (data nil)."]
            )
        }
        return data
    }

    func getReports(businessId: String, employeeUserId: String) async throws -> [PerformanceReportDTO] {
        let res: ServiceResponse<[PerformanceReportDTO]> = try await network.request(
            endpoint: .performanceReports(businessId: businessId, employeeUserId: employeeUserId),
            method: .get,
            body: nil
        )

        return res.data ?? []
    }

    func getReportDetail(reportId: String) async throws -> PerformanceReportDTO {
        let res: ServiceResponse<PerformanceReportDTO> = try await network.request(
            endpoint: .performanceReportDetail(reportId: reportId),
            method: .get,
            body: nil
        )

        guard let data = res.data else {
            throw NSError(
                domain: "performance",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: res.message ?? "Rapor detayı alınamadı (data nil)."]
            )
        }
        return data
    }
}
