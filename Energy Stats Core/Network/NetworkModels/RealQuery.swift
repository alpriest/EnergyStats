//
//  RealQueryResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

public struct RealQueryResponse: Decodable {
    public let datas: [RealData]
    public let time: Date

    public struct RealData: Decodable {
        let unit: String
        let variable: String
        let value: Double
    }
}

public struct RealQueryRequest: Encodable {
    public let deviceSN: String
    public let variables: [String]
}
