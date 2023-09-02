//
//  TotalsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/08/2023.
//

import Foundation

public struct TotalsViewModel {
    public init(reports: [ReportResponse]) {
        self.home = reports.todayValue(for: ReportVariable.loads)
        self.gridExport = reports.todayValue(for: ReportVariable.feedIn)
        self.gridImport = reports.todayValue(for: ReportVariable.gridConsumption)
    }

    public var home: Double
    public var gridImport: Double
    public var gridExport: Double
}

private extension Array where Element == ReportResponse {
    func today(for key: ReportVariable) -> ReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: Date()).day else { return nil }
        return self.first(where: { $0.variable.lowercased() == key.rawValue.lowercased() })?.data.first(where: { $0.index == currentDateIndex })
    }

    func todayValue(for key: ReportVariable) -> Double {
        self.today(for: key)?.value ?? 0.0
    }
}
