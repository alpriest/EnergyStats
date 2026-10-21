//
//  PriceRateEditor.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2026.
//

import Energy_Stats_Core
import SwiftUI

private struct PriceRateEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var price: String
    @State private var effectiveFrom: Date
    let rate: EnergyPriceRate
    let currencySymbol: String
    let onSave: (EnergyPriceRate) -> Void

    init(rate: EnergyPriceRate, currencySymbol: String, onSave: @escaping (EnergyPriceRate) -> Void) {
        self.rate = rate
        self.currencySymbol = currencySymbol
        self.onSave = onSave
        _price = State(initialValue: rate.price.roundedToString(decimalPlaces: 3))
        _effectiveFrom = State(initialValue: rate.effectiveFrom ?? .now)
    }

    var body: some View {
        Form {
            TextField("Price per kWh", text: $price)
                .keyboardType(.decimalPad)
            DatePicker("Applies from", selection: $effectiveFrom, displayedComponents: .date)
        }
        .navigationTitle("Price")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(EnergyPriceRate(
                        id: rate.id,
                        price: price.asCurrencyStringToDouble(),
                        effectiveFrom: rate.effectiveFrom == nil ? nil : effectiveFrom.startOfDay()
                    ))
                    dismiss()
                }
                .disabled(price.asCurrencyStringToDouble() < 0)
            }
        }
    }
}

#Preview {
    PriceRateEditor(
        rate: EnergyPriceRate(price: 5.0),
        currencySymbol: "£",
        onSave: { _ in }
    )
}
