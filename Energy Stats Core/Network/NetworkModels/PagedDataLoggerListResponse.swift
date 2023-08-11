//
//  PagedDataLoggerListResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 11/08/2023.
//

import Foundation

public struct PagedDataLoggerListResponse: Decodable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let data: [DataLogger]

    public struct DataLogger: Decodable, Hashable {
        public let moduleSN: String
        public let moduleType: String
        public let plantName: String
        public let version: String
        public let signal: Int
        public let communication: Int
    }
}

struct DataLoggerListRequest: Encodable {
    let pageSize = 10
    let currentPage = 1
    let total = 0
    let condition = Condition()

    struct Condition: Encodable {
        let communication: Int = 0
        let moduleSN: String = ""
        let moduleType: String = ""
    }
}
