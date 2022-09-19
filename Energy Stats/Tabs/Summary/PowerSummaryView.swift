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

struct PowerSummaryView: View {
    @State private var iconFooterSize: CGSize = .zero
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
                    VStack {
                        Text(viewModel.batteryStateOfCharge, format: .percent)
                        OptionalView(viewModel.batteryExtra) {
                            Text($0)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .background(GeometryReader { reader in
                        Color.clear.preference(key: BatterySizePreferenceKey.self, value: reader.size)
                            .onPreferenceChange(BatterySizePreferenceKey.self) { size in
                                iconFooterSize = size
                            }
                    })
                }
                .frame(width: powerViewWidth)

                Spacer()

                VStack {
                    PowerFlowView(amount: viewModel.home)
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .frame(width: 45, height: 45)
                    Color.clear.frame(width: iconFooterSize.width, height: iconFooterSize.height)
                }
                .frame(width: powerViewWidth)

                Spacer()

                VStack {
                    PowerFlowView(amount: viewModel.grid)
                    PylonView()
                        .frame(width: 45, height: 45)
                    Color.clear.frame(width: iconFooterSize.width, height: iconFooterSize.height)
                }
                .frame(width: powerViewWidth)
            }
            .padding(.horizontal, 14)
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        PowerSummaryView(viewModel: PowerFlowViewModel(solar: 2.5, battery: -0.01, home: 1.5, grid: 0.71, batteryStateOfCharge: 0.99))
    }
}
