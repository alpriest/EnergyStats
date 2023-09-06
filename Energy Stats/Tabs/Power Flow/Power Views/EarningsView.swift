//
//  EarningsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2023.
//

import Energy_Stats_Core
import SwiftUI
import OrderedCollections

struct EarningsView: View {
    let viewModel: EarningsViewModel
    let pairs: OrderedDictionary<LocalizedString.Key, KeyPath<EarningsViewModel, Double>> = [
        .today: \.today,
        .month: \.month,
        .year: \.year,
        .cumulate: \.cumulate
    ]

    var body: some View {
        HStack {
            ForEach(Array(pairs), id: \.key) { title, keyPath in
                SubLabelledView(
                    value: viewModel[keyPath: keyPath].roundedToString(decimalPlaces: 2, currencySymbol: viewModel.currencySymbol),
                    label: String(key: title),
                    alignment: .center
                )
            }
        }
    }
}

struct EarningsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsView(viewModel: .any())
    }
}
