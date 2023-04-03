//
//  Report.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct ReportRequest: Encodable {
    let deviceID: String
    let reportType = "day"
    let variables: [String]
    let queryDate: QueryDate

    internal init(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) {
        self.deviceID = deviceID
        self.variables = variables.map { $0.networkTitle }
        self.queryDate = queryDate
    }
}

public struct QueryDate: Encodable {
    let year: Int
    let month: Int
    let day: Int

    public static func current() -> QueryDate {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return QueryDate(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }
}

public struct ReportResponse: Decodable {
    public let variable: String
    public let data: [ReportData]

    public struct ReportData: Decodable {
        public let index: Int
        public let value: Double
    }
}
