//
//  PagedDataLoggerListResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 11/08/2023.
//

import Foundation

public struct DataLoggerResponse: Codable, Hashable {
    public let moduleSN: String
    public let stationID: String
    public let status: DataLoggerStatus
    public let signal: Int
}

public enum DataLoggerStatus: Int, RawRepresentable, Codable {
    case unknown = 0
    case online = 1
    case offline = 2
}

struct DataLoggerListRequest: Encodable {
    let pageSize = 20
    let currentPage = 1
}
