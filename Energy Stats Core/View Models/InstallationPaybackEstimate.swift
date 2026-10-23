//
//  InstallationPaybackEstimate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/10/2026.
//

import Combine
import Foundation

public struct InstallationPaybackEstimate {
    public let monthsRemaining: Int

    public init?(installationPurchasePrice: Double, totalSavingsToDate: Double, installationDate: Date) {
        let monthsSinceInstallation = installationDate.months(between: Date.now)

        guard installationPurchasePrice.isFinite,
              totalSavingsToDate.isFinite,
              totalSavingsToDate > 0,
              monthsSinceInstallation > 0
        else {
            return nil
        }

        let monthlyBenefit = totalSavingsToDate / Double(monthsSinceInstallation)
        let installationPurchasePriceRemaining = installationPurchasePrice - totalSavingsToDate
        let monthsRemaining = installationPurchasePriceRemaining / monthlyBenefit

        guard monthlyBenefit.isFinite,
              monthlyBenefit > 0,
              monthsRemaining.isFinite,
              monthsRemaining > Double(Int.min),
              monthsRemaining < Double(Int.max)
        else {
            return nil
        }

        self.monthsRemaining = Int(monthsRemaining)
    }
}
