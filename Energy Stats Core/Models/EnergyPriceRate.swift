//
//  EnergyPriceRate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2026.
//

import Foundation

public struct EnergyPriceRate: Codable, Equatable, Identifiable {
    public let id: UUID
    public var price: Double
    public var effectiveFrom: Date?

    public init(id: UUID = UUID(), price: Double, effectiveFrom: Date? = nil) {
        self.id = id
        self.price = price
        self.effectiveFrom = effectiveFrom
    }
}
