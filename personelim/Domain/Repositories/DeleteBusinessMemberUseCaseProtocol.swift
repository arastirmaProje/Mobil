//
//  DeleteBusinessMemberUseCaseProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

protocol DeleteBusinessMemberUseCaseProtocol {
    func execute(memberId: String) async throws
}
