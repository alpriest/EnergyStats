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

struct QueryDate: Encodable {
    let year: Int
    let month: Int
    let day: Int

    static func current() -> QueryDate {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return QueryDate(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }
}

struct ReportResponse: Decodable {
    let variable: String
    let data: [ReportData]

    struct ReportData: Decodable {
        let index: Int
        let value: Double
    }
}
