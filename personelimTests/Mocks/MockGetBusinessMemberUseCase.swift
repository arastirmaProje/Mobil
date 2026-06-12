//
//  MockGetBusinessMemberUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation
@testable import personelim

final class MockGetBusinessMemberUseCase: GetBusinessMemberUseCaseProtocol {

    var result: Result<BusinessMemberDTO, Error> = .failure(MockError.sample)

    func execute(memberId: String) async throws -> BusinessMemberDTO {
        try result.get()
    }
}
