//
//  PerformanceReportDTO.mock.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation
import XCTest
@testable import personelim

extension PerformanceReportDTO {

    static func mock(
        totalWorkedSeconds: Int = 3600,
        averageDailySeconds: Int = 1800
    ) -> PerformanceReportDTO {

        let json = """
        {
            "totalWorkedSeconds": \(totalWorkedSeconds),
            "averageDailySeconds": \(averageDailySeconds),
            "days": []
        }
        """

        let data = json.data(using: .utf8)!

        return try! JSONDecoder().decode(
            PerformanceReportDTO.self,
            from: data
        )
    }
}
