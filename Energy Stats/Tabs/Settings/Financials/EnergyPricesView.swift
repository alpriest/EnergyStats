//
//  EnergyPricesView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2026.
//

import Energy_Stats_Core
import SwiftUI

struct EnergyPricesView: View {
    @State private var configManager: ConfigManaging
    @State private var selectedKind: EnergyPriceKind
    @State private var displayedRates: [EnergyPriceRate]
    @State private var editingRate: EnergyPriceRate?

    init(configManager: ConfigManaging, initialKind: EnergyPriceKind) {
        self.configManager = configManager
        _selectedKind = State(initialValue: initialKind)
        _displayedRates = State(initialValue: initialKind == .export
            ? configManager.feedInPriceRates
            : configManager.gridImportPriceRates)
    }

    private var rates: [EnergyPriceRate] {
        displayedRates
    }

    var body: some View {
        Form {
            Picker("Price type", selection: $selectedKind) {
                ForEach(EnergyPriceKind.allCases) { kind in
                    Text(kind == .export ? "Export" : "Import").tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedKind) { _, newKind in
                displayedRates = newKind == .export
                    ? configManager.feedInPriceRates
                    : configManager.gridImportPriceRates
            }

            Section {
                ForEach(rates.sortedForDisplay()) { rate in
                    Button {
                        editingRate = rate
                    } label: {
                        PriceRateRow(rate: rate, allRates: rates, currencySymbol: configManager.currencySymbol)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteRates)

                Button("Add price change") {
                    editingRate = EnergyPriceRate(price: currentPrice, effectiveFrom: .now)
                }
            } header: {
                Text(selectedKind.title)
            } footer: {
                Text("Prices are automatically apportioned by calendar day when a report covers more than one price period.")
            }
        }
        .navigationTitle("Energy prices")
        .sheet(item: $editingRate) { rate in
            NavigationStack {
                PriceRateEditor(rate: rate, currencySymbol: configManager.currencySymbol) { updatedRate in
                    save(updatedRate)
                    editingRate = nil
                }
            }
        }
    }

    private var currentPrice: Double {
        rates.price(for: .now)
    }

    private func save(_ rate: EnergyPriceRate) {
        let calendar = Calendar.current
        let normalizedRate = EnergyPriceRate(
            id: rate.id,
            price: rate.price,
            effectiveFrom: rate.effectiveFrom.map { calendar.startOfDay(for: $0) }
        )
        var updated = rates.filter { existing in
            existing.id != rate.id && !sameEffectiveDate(existing.effectiveFrom, normalizedRate.effectiveFrom)
        }
        updated.append(normalizedRate)
        if selectedKind == .export {
            configManager.feedInPriceRates = updated
        } else {
            configManager.gridImportPriceRates = updated
        }
        displayedRates = updated
    }

    private func sameEffectiveDate(_ lhs: Date?, _ rhs: Date?) -> Bool {
        switch (lhs, rhs) {
        case let (lhs?, rhs?): return Calendar.current.isDate(lhs, inSameDayAs: rhs)
        case (nil, nil): return true
        default: return false
        }
    }

    private func deleteRates(at offsets: IndexSet) {
        let displayed = rates.sortedForDisplay()
        let deletedIDs = offsets.map { displayed[$0].id }
        let updated = rates.filter { !deletedIDs.contains($0.id) }
        let ratesAfterDeletion = updated.isEmpty
            ? [EnergyPriceRate(price: currentPrice)]
            : updated

        if selectedKind == .export {
            configManager.feedInPriceRates = ratesAfterDeletion
        } else {
            configManager.gridImportPriceRates = ratesAfterDeletion
        }
        displayedRates = ratesAfterDeletion
    }
}
