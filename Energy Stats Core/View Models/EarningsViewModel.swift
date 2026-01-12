//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Combine
import Foundation

public class EnergyStatsFinancialModel: ObservableObject {
    private let config: FinancialConfigManager
    private var cancellables = Set<AnyCancellable>()

    @Published public private(set) var exportIncome: FinanceAmount
    @Published public private(set) var exportBreakdown: CalculationBreakdown
    @Published public private(set) var solarSaving: FinanceAmount
    @Published public private(set) var solarSavingBreakdown: CalculationBreakdown
    @Published public private(set) var total: FinanceAmount
    @Published public private(set) var amounts: [FinanceAmount] = []

    private let totalsViewModel: TotalsViewModel

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManager) {
        self.totalsViewModel = totalsViewModel
        self.config = config

        // Compute once for initial values
        let initial = EnergyStatsFinancialModel.computeValues(
            totalsViewModel: totalsViewModel,
            config: config
        )
        self.exportIncome = initial.exportIncome
        self.exportBreakdown = initial.exportBreakdown
        self.solarSaving = initial.solarSaving
        self.solarSavingBreakdown = initial.solarSavingBreakdown
        self.total = initial.total
        self.amounts = [exportIncome, solarSaving, total]

        // Then subscribe and update on changes
        config.appSettingsPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &cancellables)
    }

    private static func computeValues(
        totalsViewModel: TotalsViewModel,
        config: FinancialConfigManager
    ) -> (
        exportIncome: FinanceAmount,
        exportBreakdown: CalculationBreakdown,
        solarSaving: FinanceAmount,
        solarSavingBreakdown: CalculationBreakdown,
        total: FinanceAmount
    ) {
        let amountForIncomeCalculation: Double = {
            switch config.earningsModel {
            case .exported: return totalsViewModel.gridExport
            case .generated: return totalsViewModel.solar
            case .ct2: return totalsViewModel.ct2
            }
        }()

        let nameForIncomeCalculationBreakdown: String = {
            switch config.earningsModel {
            case .exported: return String(key: .exportedIncomeShortTitle)
            case .generated: return String(key: .generatedIncomeShortTitle)
            case .ct2: return "CT2"
            }
        }()

        let exportIncome: FinanceAmount = {
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
        }()

        let exportBreakdown = CalculationBreakdown(
            formula: "\(nameForIncomeCalculationBreakdown) * feedInUnitPrice",
            calculation: { dp in
                "\(amountForIncomeCalculation.roundedToString(decimalPlaces: dp)) * \(config.feedInUnitPrice.roundedToString(decimalPlaces: dp))"
            }
        )

        let solarSavingAmount = max(0, totalsViewModel.solar - totalsViewModel.gridExport) * config.gridImportUnitPrice

        let solarSaving = FinanceAmount(
            title: .gridImportAvoidedShortTitle,
            accessibilityKey: .totalAvoidedCostsToday,
            amount: solarSavingAmount
        )

        let solarSavingBreakdown = CalculationBreakdown(
            formula: "max(0, solar - gridExport) * gridImportUnitPrice",
            calculation: { dp in
                "max (0, \(totalsViewModel.solar.roundedToString(decimalPlaces: dp)) - \(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp))) * \(config.gridImportUnitPrice.roundedToString(decimalPlaces: dp))"
            }
        )

        let total = FinanceAmount(
            title: .total,
            accessibilityKey: .totalIncomeToday,
            amount: exportIncome.amount + solarSaving.amount
        )

        return (exportIncome, exportBreakdown, solarSaving, solarSavingBreakdown, total)
    }

    private func update() {
        let computed = Self.computeValues(totalsViewModel: totalsViewModel, config: config)
        exportIncome = computed.exportIncome
        exportBreakdown = computed.exportBreakdown
        solarSaving = computed.solarSaving
        solarSavingBreakdown = computed.solarSavingBreakdown
        total = computed.total
        amounts = [exportIncome, solarSaving, total]
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
