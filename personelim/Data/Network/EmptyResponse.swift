//
//  EmptyResponse.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.12.2025.
//

import Foundation

struct EmptyResponse: Decodable {}

struct IgnoredResponse: Decodable {
    init(from decoder: Decoder) throws {}
}
