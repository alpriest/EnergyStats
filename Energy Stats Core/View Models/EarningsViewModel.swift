//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct FinanceAmount: Hashable, Identifiable {
    public let shortTitle: LocalizedString.Key
    public let longTitle: LocalizedString.Key
    public let accessibilityKey: LocalizedString.Key.Accessibility
    public let amount: Double

    public init(shortTitle: LocalizedString.Key, longTitle: LocalizedString.Key, accessibilityKey: LocalizedString.Key.Accessibility, amount: Double) {
        self.shortTitle = shortTitle
        self.longTitle = longTitle
        self.accessibilityKey = accessibilityKey
        self.amount = amount
    }

    public init(title: LocalizedString.Key, accessibilityKey: LocalizedString.Key.Accessibility, amount: Double) {
        self.init(shortTitle: title, longTitle: title, accessibilityKey: accessibilityKey, amount: amount)
    }

    public func formattedAmount(_ currencySymbol: String) -> String {
        amount.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol)
    }

    public func accessibilityLabel(_ currencySymbol: String) -> String {
        String(format: String(accessibilityKey: accessibilityKey), arguments: [formattedAmount(currencySymbol)])
    }

    public var id: String { shortTitle.rawValue }
}

public struct EnergyStatsFinancialModel {
    private let config: FinancialConfigManager
    public var exportIncome: FinanceAmount {
        let shortTitle: LocalizedString.Key = switch config.earningsModel {
        case .exported: .exportedIncomeShortTitle
        case .generated: .generatedIncomeShortTitle
        case .ct2: .ct2IncomeShortTitle
        }

        let longTitle: LocalizedString.Key = switch config.earningsModel {
        case .exported: .exportedIncomeLongTitle
        case .generated: .generationIncomeLongTitle
        case .ct2: .ct2IncomeLongTitle
        }

        let accessibilityKey: LocalizedString.Key.Accessibility = switch config.earningsModel {
        case .exported: .totalExportIncomeToday
        case .generated: .totalGeneratedIncomeToday
        case .ct2: .totalCT2IncomeToday
        }

        return FinanceAmount(
            shortTitle: shortTitle,
            longTitle: longTitle,
            accessibilityKey: accessibilityKey,
            amount: amountForIncomeCalculation * config.feedInUnitPrice
        )
    }

    public var exportBreakdown: CalculationBreakdown {
        CalculationBreakdown(
            formula: "\(nameForIncomeCalculationBreakdown) * feedInUnitPrice",
            calculation: { dp in "\(amountForIncomeCalculation.roundedToString(decimalPlaces: dp)) * \(config.feedInUnitPrice.roundedToString(decimalPlaces: dp))" }
        )
    }

    public var solarSaving: FinanceAmount {
        FinanceAmount(
            title: .gridImportAvoidedShortTitle,
            accessibilityKey: .totalAvoidedCostsToday,
            amount: max(0, totalsViewModel.solar - totalsViewModel.gridExport) * config.gridImportUnitPrice
        )
    }

    public var solarSavingBreakdown: CalculationBreakdown {
        CalculationBreakdown(
            formula: "max(0, solar - gridExport) * gridImportUnitPrice",
            calculation: { dp in "max (0, \(totalsViewModel.solar.roundedToString(decimalPlaces: dp)) - \(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp))) * \(config.gridImportUnitPrice.roundedToString(decimalPlaces: dp))" }
        )
    }

    public var total: FinanceAmount {
        FinanceAmount(
            title: .total,
            accessibilityKey: .totalIncomeToday,
            amount: exportIncome.amount + solarSaving.amount
        )
    }

    private let totalsViewModel: TotalsViewModel

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManager) {
        self.totalsViewModel = totalsViewModel
        self.config = config
    }

    public func amounts() -> [FinanceAmount] {
        [exportIncome, solarSaving, total]
    }

    private var amountForIncomeCalculation: Double {
        switch config.earningsModel {
        case .exported:
            totalsViewModel.gridExport
        case .generated:
            totalsViewModel.solar
        case .ct2:
            totalsViewModel.ct2
        }
    }

    private var nameForIncomeCalculationBreakdown: String {
        switch config.earningsModel {
        case .exported:
            String(key: .exportedIncomeShortTitle)
        case .generated:
            String(key: .generatedIncomeShortTitle)
        case .ct2:
            "CT2"
        }
    }
}

public extension EnergyStatsFinancialModel {
    static func any() -> EnergyStatsFinancialModel {
        EnergyStatsFinancialModel(
            totalsViewModel: TotalsViewModel(
                reports: [],
                generationViewModel: GenerationViewModel(
                    response: OpenHistoryResponse(deviceSN: "", datas: []),
                    includeCT2: false,
                    shouldInvertCT2: false
                )
            ),
            config: ConfigManager.preview()
        )
    }

    static func empty() -> EnergyStatsFinancialModel { any() }
}
