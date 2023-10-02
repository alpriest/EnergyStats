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
            ForEach(viewModel.amounts(appTheme.financialModel), id: \.self) { amount in
                SubLabelledView(
                    value: amount.formattedAmount(),
                    label: String(key: amount.title),
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
