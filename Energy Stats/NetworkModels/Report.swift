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
    let variables = ["feedin", "generation", "gridConsumption", "chargeEnergyToTal", "dischargeEnergyToTal", "loads"]
    let queryDate: QueryDate

    internal init(deviceID: String) {
        self.deviceID = deviceID

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
    let result: [ReportVariable]

    struct ReportVariable: Decodable {
        let variable: String
        let data: [ReportData]
    }

    struct ReportData: Decodable {
        let index: Int
        let value: Double
    }
}
