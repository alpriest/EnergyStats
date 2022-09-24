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

    internal init(deviceID: String, variables: [VariableType]) {
        self.deviceID = deviceID
        self.variables = variables.map { $0.reportTitle }

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        self.queryDate = QueryDate(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }
}

struct QueryDate: Encodable {
    let year: Int
    let month: Int
    let day: Int
}

struct ReportResponse: Decodable {
    let variable: String
    let data: [ReportData]

    struct ReportData: Decodable {
        let index: Int
        let value: Double
    }
}
