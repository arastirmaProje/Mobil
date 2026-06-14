//
//  ChatEntityResolver.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

struct ChatResolvedEntity {
    let departmentId: String?
    let employeeUserId: String?
}

enum ChatEntityResolver {

    static func resolve(
        message: String,
        members: [BusinessMemberDTO],
        departments: [DepartmentResponseDTO]
    ) -> ChatResolvedEntity {

        let departmentId = bestDepartmentMatch(
            message: message,
            departments: departments
        )?.id

        let employeeUserId = bestMemberMatch(
            message: message,
            members: members
        )?.userId

        return ChatResolvedEntity(
            departmentId: departmentId,
            employeeUserId: employeeUserId
        )
    }

    private static func bestDepartmentMatch(
        message: String,
        departments: [DepartmentResponseDTO]
    ) -> DepartmentResponseDTO? {
        let normalizedMessage = normalize(message)

        return departments
            .map { department in
                (
                    department: department,
                    score: similarity(
                        normalizedMessage,
                        normalize(department.name)
                    )
                )
            }
            .filter { $0.score >= 0.55 }
            .sorted { $0.score > $1.score }
            .first?
            .department
    }

    private static func bestMemberMatch(
        message: String,
        members: [BusinessMemberDTO]
    ) -> BusinessMemberDTO? {
        let normalizedMessage = normalize(message)

        return members
            .map { member in
                (
                    member: member,
                    score: similarity(
                        normalizedMessage,
                        normalize(member.fullName)
                    )
                )
            }
            .filter { $0.score >= 0.55 }
            .sorted { $0.score > $1.score }
            .first?
            .member
    }

    private static func normalize(_ value: String) -> String {
        value
            .lowercased(with: Locale(identifier: "tr_TR"))
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: "&", with: " ")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func similarity(_ text: String, _ target: String) -> Double {
        if text.contains(target) {
            return 1
        }

        let textWords = Set(text.split(separator: " ").map(String.init))
        let targetWords = Set(target.split(separator: " ").map(String.init))

        guard !targetWords.isEmpty else {
            return 0
        }

        let intersection = textWords.intersection(targetWords).count
        let wordScore = Double(intersection) / Double(targetWords.count)

        let distance = levenshtein(text, target)
        let maxLength = max(text.count, target.count)

        guard maxLength > 0 else {
            return wordScore
        }

        let editScore = 1.0 - (Double(distance) / Double(maxLength))

        return max(wordScore, editScore)
    }

    private static func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let lhs = Array(lhs)
        let rhs = Array(rhs)

        var distances = Array(
            repeating: Array(repeating: 0, count: rhs.count + 1),
            count: lhs.count + 1
        )

        for i in 0...lhs.count {
            distances[i][0] = i
        }

        for j in 0...rhs.count {
            distances[0][j] = j
        }

        for i in 1...lhs.count {
            for j in 1...rhs.count {
                if lhs[i - 1] == rhs[j - 1] {
                    distances[i][j] = distances[i - 1][j - 1]
                } else {
                    distances[i][j] = min(
                        distances[i - 1][j] + 1,
                        distances[i][j - 1] + 1,
                        distances[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return distances[lhs.count][rhs.count]
    }
}
