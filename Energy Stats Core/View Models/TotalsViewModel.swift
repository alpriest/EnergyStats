//
//  TotalsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/08/2023.
//

import Foundation

public struct CalculationBreakdown {
    public let formula: String
    public let calculation: (Int) -> String

    public init(formula: String, calculation: @escaping (Int) -> String) {
        self.formula = formula
        self.calculation = calculation
    }
}

public struct TotalsViewModel {
    public init(reports: [OpenReportResponse], generationViewModel: GenerationViewModel?) {
        let home = reports.todayValue(for: ReportVariable.loads)
        let gridExport = reports.todayValue(for: ReportVariable.feedIn)
        let gridImport = reports.todayValue(for: ReportVariable.gridConsumption)
        let solar = reports.todayValue(for: ReportVariable.pvEnergyTotal)

        self.init(grid: gridImport, feedIn: gridExport, loads: home, solar: solar, ct2: generationViewModel?.ct2Total ?? 0)
    }

    public init(grid: Double,
                feedIn: Double,
                loads: Double,
                solar: Double,
                ct2: Double)
    {
        self.home = loads
        self.gridExport = feedIn
        self.gridImport = grid
        self.solar = solar
        self.ct2 = ct2
    }

    public let home: Double
    public let gridImport: Double
    public let gridExport: Double
    public let solar: Double
    public let ct2: Double
}

public extension Array where Element == OpenReportResponse {
    func value(for key: ReportVariable, date: Date) -> OpenReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: date).day else { return nil }
        return first(where: { $0.variable.lowercased() == key.networkTitle.lowercased() })?.values.first(where: { $0.index == currentDateIndex })
    }
}

public extension Array where Element == OpenReportResponse {
    func todayValue(for key: ReportVariable) -> Double {
        dateValue(for: key, date: Date())
    }
    
    func dateValue(for key: ReportVariable, date: Date) -> Double {
        value(for: key, date: date)?.value ?? 0.0
    }
}
