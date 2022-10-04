//
//  PowerSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct BatterySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct HomePowerFlowView: View {
    @State private var iconFooterSize: CGSize = .zero
    @State private var lastUpdated = Date()
    let viewModel: HomePowerFlowViewModel
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
                .padding(.vertical, 1)

            HStack {
                BatteryPowerView(viewModel: viewModel, iconFooterSize: $iconFooterSize)
                    .frame(width: powerViewWidth)
                    .opacity(viewModel.hasBattery ? 1.0 : 0.5)

                Spacer()

                HomePowerView(amount: viewModel.home, iconFooterSize: iconFooterSize)
                    .frame(width: powerViewWidth)

                Spacer()

                GridPowerView(amount: viewModel.grid, iconFooterSize: iconFooterSize)
                    .frame(width: powerViewWidth)
            }
            .padding(.horizontal, 14)
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFlowView(viewModel: HomePowerFlowViewModel.any())
    }
}

extension HomePowerFlowViewModel {
    static func any() -> HomePowerFlowViewModel {
        .init(config: MockConfig(), solar: 2.5, battery: -0.01, home: 1.5, grid: 0.71, batteryStateOfCharge: 0.99, hasBattery: true)
    }
}
