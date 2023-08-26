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
    @State private var appTheme: AppTheme = .mock()
    @State private var batteryPowerWidth: CGFloat = 0.0
    @State private var homePowerWidth: CGFloat = 0.0
    @State private var gridPowerWidth: CGFloat = 0.0
    @State private var size: CGSize = .zero
    private let configManager: ConfigManaging
    private let viewModel: HomePowerFlowViewModel
    private var appThemePublisher: LatestAppTheme

    init(configManager: ConfigManaging, viewModel: HomePowerFlowViewModel, appThemePublisher: LatestAppTheme) {
        self.configManager = configManager
        self.viewModel = viewModel
        self.appThemePublisher = appThemePublisher
        self.appTheme = appThemePublisher.value
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SolarPowerView(appTheme: appTheme, viewModel: SolarPowerViewModel(solar: viewModel.solar,
                                                                              generation: viewModel.todaysGeneration,
                                                                              earnings: viewModel.earnings))
                .frame(height: size.height * 0.4)

            InverterView(viewModel: InverterViewModel(configManager: configManager, temperatures: viewModel.inverterTemperatures), appTheme: appTheme)
                .frame(height: 2)
                .frame(width: batteryPowerWidth + gridPowerWidth + 20)
                .padding(.vertical, 2)
                .zIndex(1)

            HStack {
                if viewModel.hasBattery {
                    BatteryPowerView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                      batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                      batteryChargekWH: viewModel.battery,
                                                                      temperature: viewModel.batteryTemperature,
                                                                      batteryResidual: viewModel.batteryResidual),
                                     iconFooterSize: $iconFooterSize,
                                     appTheme: appTheme)
                        .background(GeometryReader { reader in
                            Color.clear.preference(key: BatteryFlowSizePreferenceKey.self, value: reader.size)
                                .onPreferenceChange(BatteryFlowSizePreferenceKey.self) { size in
                                    batteryPowerWidth = size.width
                                }
                        })

                    Spacer()
                }

                HomePowerView(amount: viewModel.home, total: viewModel.homeTotal, iconFooterSize: iconFooterSize, appTheme: appTheme)
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
            .padding(.bottom, 16)
        }.background(GeometryReader { reader in
            Color.clear.onAppear { size = reader.size }.onChange(of: reader.size) { newValue in size = newValue }
        })
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFlowView(configManager: PreviewConfigManager(),
                          viewModel: HomePowerFlowViewModel.any(),
                          appThemePublisher: CurrentValueSubject(AppTheme.mock(decimalPlaces: 3, showInW: false, showInverterTemperature: true)))
            .environment(\.locale, .init(identifier: "de"))
    }
}

extension HomePowerFlowViewModel {
    static func any() -> HomePowerFlowViewModel {
        .init(solar: 2.5,
              battery: -0.01,
              home: 1.5,
              grid: 0.71,
              batteryStateOfCharge: 0.99,
              hasBattery: true,
              batteryTemperature: 15.6,
              batteryResidual: 5678,
              todaysGeneration: 8.5,
              earnings: "GBP(£) 1 / 5 / 99",
              inverterTemperatures: InverterTemperatures(ambient: 4.0, inverter: 9.0),
              homeTotal: 1.0)
    }
}
