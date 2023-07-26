//
//  PowerSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatteryFlowSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct HomeFlowSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct GridFlowSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct HomePowerFlowView: View {
    @State private var iconFooterSize: CGSize = .zero
    @State private var lastUpdated = Date()
    let configManager: ConfigManaging
    let viewModel: HomePowerFlowViewModel
    let appTheme: AppTheme
    let networking: Networking
    @State var batteryPowerWidth: CGFloat = 0.0
    @State var homePowerWidth: CGFloat = 0.0
    @State var gridPowerWidth: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SolarPowerView(appTheme: appTheme, viewModel: SolarPowerViewModel(solar: viewModel.solar,
                                                                              generation: viewModel.todaysGeneration,
                                                                              earnings: viewModel.earnings))

            InverterView(viewModel: InverterViewModel(configManager: configManager))
                .frame(height: 2)
                .frame(width: batteryPowerWidth + gridPowerWidth + 16)
                .padding(.vertical, 1)
                .zIndex(1)

            HStack {
                if viewModel.hasBattery {
                    BatteryPowerView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                      batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                      batteryChargekWH: viewModel.battery,
                                                                      temperature: viewModel.batteryTemperature,
                                                                      batteryResidual: viewModel.batteryResidual),
                                     iconFooterSize: $iconFooterSize,
                                     appTheme: appTheme,
                                     networking: networking,
                                     config: configManager)
                        .background(GeometryReader { reader in
                            Color.clear.preference(key: BatteryFlowSizePreferenceKey.self, value: reader.size)
                                .onPreferenceChange(BatteryFlowSizePreferenceKey.self) { size in
                                    batteryPowerWidth = size.width
                                }
                        })

                    Spacer()
                }

                HomePowerView(amount: viewModel.home, iconFooterSize: iconFooterSize, appTheme: appTheme)
                    .background(GeometryReader { reader in
                        Color.clear.preference(key: HomeFlowSizePreferenceKey.self, value: reader.size)
                            .onPreferenceChange(HomeFlowSizePreferenceKey.self) { size in
                                homePowerWidth = size.width
                            }
                    })

                Spacer()

                GridPowerView(amount: viewModel.grid, iconFooterSize: iconFooterSize, appTheme: appTheme)
                    .background(GeometryReader { reader in
                        Color.clear.preference(key: GridFlowSizePreferenceKey.self, value: reader.size)
                            .onPreferenceChange(GridFlowSizePreferenceKey.self) { size in
                                gridPowerWidth = size.width
                            }
                    })
            }
            .padding(.horizontal, 14)
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFlowView(configManager: PreviewConfigManager(),
                          viewModel: HomePowerFlowViewModel.any(),
                          appTheme: AppTheme.mock(decimalPlaces: 3, showInW: false),
                          networking: DemoNetworking())
            .environment(\.locale, .init(identifier: "de"))
    }
}

extension HomePowerFlowViewModel {
    static func any() -> HomePowerFlowViewModel {
        .init(solar: 2.5, battery: -0.01, home: 1.5, grid: 0.71, batteryStateOfCharge: 0.99, hasBattery: true, batteryTemperature: 15.6, batteryResidual: 5678, todaysGeneration: 8.5, earnings: "GBP(£) 1 / 5 / 99")
    }
}
