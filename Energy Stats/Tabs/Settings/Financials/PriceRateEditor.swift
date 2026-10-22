//
//  PriceRateEditor.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2026.
//

import Energy_Stats_Core
import SwiftUI

struct PriceRateEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var price: String
    @State private var effectiveFrom: Date
    let rate: EnergyPriceRate
    let currencySymbol: String
    let includeDatePicker: Bool
    let onSave: (EnergyPriceRate) -> Void
    let onDelete: (EnergyPriceRate) -> Void

    init(
        rate: EnergyPriceRate,
        currencySymbol: String,
        includeDatePicker: Bool,
        onSave: @escaping (EnergyPriceRate) -> Void,
        onDelete: @escaping (EnergyPriceRate) -> Void
    ) {
        self.rate = rate
        self.currencySymbol = currencySymbol
        self.includeDatePicker = includeDatePicker
        self.onSave = onSave
        self.onDelete = onDelete
        _price = State(initialValue: rate.price.roundedToString(decimalPlaces: 3))
        _effectiveFrom = State(initialValue: rate.effectiveFrom ?? .now)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(currencySymbol)
                    TextField("Price per kWh", text: $price)
                        .keyboardType(.decimalPad)
                }
                if includeDatePicker {
                    DatePicker("Applies from", selection: $effectiveFrom, displayedComponents: .date)
                }
            } footer: {
                Button("Delete", role: .destructive) {
                    onDelete(rate)
                    dismiss()
                }
            }
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
    NavigationStack {
        PriceRateEditor(
            rate: EnergyPriceRate(
                price: 5.0),
            currencySymbol: "£",
            includeDatePicker: true,
            onSave: { _ in },
            onDelete: { _ in }
        )
    }
}
