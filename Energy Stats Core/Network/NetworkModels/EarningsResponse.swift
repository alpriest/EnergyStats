//
//  EarningsResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 08/05/2023.
//

import Foundation

public struct EarningsResponse: Decodable {
    public let today: Earning

    public struct Earning: Decodable {
        public let generation: Double
        public let earnings: Double
    }
}