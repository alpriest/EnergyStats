//
//  PriceRateRow.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2026.
//

import Energy_Stats_Core
import SwiftUI

struct PriceRateRow: View {
    let rate: EnergyPriceRate
    let allRates: [EnergyPriceRate]
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(rate.price.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var subtitle: String {
        guard let effectiveFrom = rate.effectiveFrom else {
            guard allRates.count > 1,
                  let firstDate = allRates.compactMap(\.effectiveFrom).min()
                    else { return String(localized: "Price") }

            return String(localized: "Before") + " " + Self.dateFormatter.string(from: firstDate)
        }

        return String(localized: "Applies from") + " " + Self.dateFormatter.string(from: effectiveFrom)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
