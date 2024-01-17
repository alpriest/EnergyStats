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
    let viewModel: EnergyStatsFinancialModel
    let appSettings: AppSettings

    var body: some View {
        HStack {
            ForEach(viewModel.amounts(), id: \.self) { amount in
                SubLabelledView(
                    value: amount.formattedAmount(),
                    label: String(key: amount.title),
                    alignment: .center
                )
            }
        }
    }
}

#Preview {
    EarningsView(viewModel: .any(), appSettings: .mock())
}
