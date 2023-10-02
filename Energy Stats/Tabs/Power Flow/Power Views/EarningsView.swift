//
//  EarningsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2023.
//

import Energy_Stats_Core
import OrderedCollections
import SwiftUI

struct EarningsView: View {
    let viewModel: EarningsViewModel
    let appTheme: AppTheme

    var body: some View {
        HStack {
            SubLabelledView(
                value: viewModel.today(appTheme.financialModel).roundedToString(decimalPlaces: 2, currencySymbol: viewModel.currencySymbol),
                label: String(key: .today),
                alignment: .center
            )

            OptionalView(viewModel.month(appTheme.financialModel)) {
                SubLabelledView(
                    value: $0.roundedToString(decimalPlaces: 2, currencySymbol: viewModel.currencySymbol),
                    label: String(key: .month),
                    alignment: .center
                )
            }

            OptionalView(viewModel.year(appTheme.financialModel)) {
                SubLabelledView(
                    value: $0.roundedToString(decimalPlaces: 2, currencySymbol: viewModel.currencySymbol),
                    label: String(key: .year),
                    alignment: .center
                )
            }

            OptionalView(viewModel.cumulate(appTheme.financialModel)) {
                SubLabelledView(
                    value: $0.roundedToString(decimalPlaces: 2, currencySymbol: viewModel.currencySymbol),
                    label: String(key: .cumulate),
                    alignment: .center
                )
            }
        }
    }
}

struct EarningsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsView(viewModel: .any(), appTheme: .mock())
    }
}
