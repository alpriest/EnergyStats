//
//  Auth.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct AuthRequest: Encodable {
    let user: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
}
