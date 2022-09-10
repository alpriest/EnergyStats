//
//  PowerSummaryView.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct PowerFlowViewModel {
    let solar: Double
    let battery: Double
    let home: Double
    let grid: Double
    let batteryStateOfCharge: Double
}

struct PowerSummaryView: View {
    @State private var contentSize: CGSize = .zero
    @State private var lastUpdated = Date()
    let viewModel: PowerFlowViewModel
    private let powerViewWidth: CGFloat = 70

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 48))
                PowerFlowView(amount: viewModel.solar)
            }
            .frame(width: powerViewWidth)

            InverterView()
                .frame(height: 2)
                .padding(.horizontal, 14 + powerViewWidth / 2 - 2)

            HStack {
                VStack {
                    PowerFlowView(amount: viewModel.battery)
                    Image(systemName: "minus.plus.batteryblock.fill")
                        .font(.system(size: 48))
                        .frame(width: 45, height: 45)
                    Text(viewModel.batteryStateOfCharge, format: .percent)
                }
                .frame(width: powerViewWidth)
                .padding(.leading, 14)

                Spacer()

                VStack {
                    PowerFlowView(amount: viewModel.home)
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .frame(width: 45, height: 45)
                    Text(" ")
                }
                .frame(width: powerViewWidth)

                Spacer()

                VStack {
                    PowerFlowView(amount: viewModel.grid)
                    PylonView()
                        .frame(width: 45, height: 45)
                    Text(" ")
                }
                .frame(width: powerViewWidth)
                .padding(.trailing, 14)
            }
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        PowerSummaryView(viewModel: PowerFlowViewModel(solar: 2.5, battery: -0.01, home: 1.5, grid: 0.71, batteryStateOfCharge: 0.99))
    }
}
