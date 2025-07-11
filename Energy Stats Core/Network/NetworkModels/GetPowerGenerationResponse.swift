//
//  PowerGenerationResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

public struct PowerGenerationResponse: Decodable {
    public let today: Double
    public let month: Double
    public let cumulative: Double
}
