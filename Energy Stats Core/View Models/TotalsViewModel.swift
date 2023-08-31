//
//  TotalsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/08/2023.
//

import Foundation

public struct TotalsViewModel {
    public init(reports: [ReportResponse]) {
        self.home = reports.todayValue(for: "loads")
    }

    public var home: Double
}

private extension Array where Element == ReportResponse {
    func today(for key: String) -> ReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: Date()).day else { return nil }
        return self.first(where: { $0.variable.lowercased() == key.lowercased() })?.data.first(where: { $0.index == currentDateIndex })
    }

    func todayValue(for key: String) -> Double {
        self.today(for: key)?.value ?? 0.0
    }
}
