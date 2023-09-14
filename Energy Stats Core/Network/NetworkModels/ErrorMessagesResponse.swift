//
//  ErrorMessagesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 14/09/2023.
//

import Foundation

public struct ErrorMessagesResponse: Decodable {
    let messages: [String: [String: String]]
}
