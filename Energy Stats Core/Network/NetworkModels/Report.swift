//
//  Report.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public enum ReportType: String, RawRepresentable, Encodable {
    case day
    case month
    case year
}

struct ReportRequest: Encodable {
    let deviceID: String
    let reportType: ReportType
    let variables: [String]
    let queryDate: QueryDate

    internal init(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) {
        self.deviceID = deviceID
        self.variables = variables.map { $0.networkTitle }
        self.queryDate = queryDate
        self.reportType = reportType
    }
}

public struct QueryDate: Encodable {
    public let year: Int
    public let month: Int?
    public let day: Int?

    public static func current() -> QueryDate {
        QueryDate(from: Date())
    }

    public init(year: Int, month: Int?, day: Int?) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from date: Date) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        self.init(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }

    public func asDate() -> Date? {
        DateComponents(calendar: Calendar.current, year: year, month: month, day: day).date
    }
}

extension QueryDate: Equatable {}

public struct ReportResponse: Decodable, Hashable {
    public let variable: String
    public let data: [ReportData]

    public struct ReportData: Decodable, Hashable {
        public let index: Int
        public let value: Double
    }
}
