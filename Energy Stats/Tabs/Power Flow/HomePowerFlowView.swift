//
//  PowerSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct HomePowerFlowView: View {
    @State private var iconFooterHeight: Double = 0
    @State private var lastUpdated = Date()
    @State private var appTheme: AppTheme = .mock()
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
                .frame(width: inverterLineWidth)
                .padding(.vertical, 2)
                .zIndex(1)

            HStack(alignment: .top) {
                if viewModel.hasBattery || viewModel.hasBatteryError {
                    BatteryPowerView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                      batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                      batteryChargekWH: viewModel.battery,
                                                                      temperature: viewModel.batteryTemperature,
                                                                      batteryResidual: viewModel.batteryResidual,
                                                                      error: viewModel.batteryError),
                                     appTheme: appTheme)
                        .frame(width: columnWidth)

                    Spacer().frame(width: horizontalPadding)
                }

                HomePowerView(amount: viewModel.home, appTheme: appTheme)
                    .frame(width: columnWidth)

                Spacer().frame(width: horizontalPadding)

                GridPowerView(amount: viewModel.grid, appTheme: appTheme)
                    .frame(width: columnWidth)
            }
            .padding(.bottom, 4)
            .padding(.horizontal, horizontalPadding)

            // Totals
            HStack(alignment: .top) {
                if viewModel.hasBattery || viewModel.hasBatteryError {
                    BatteryPowerFooterView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                            batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                            batteryChargekWH: viewModel.battery,
                                                                            temperature: viewModel.batteryTemperature,
                                                                            batteryResidual: viewModel.batteryResidual,
                                                                            error: viewModel.batteryError),
                                           appTheme: appTheme)
                        .frame(width: columnWidth)

                    Spacer().frame(width: horizontalPadding)
                }

                HomePowerFooterView(amount: viewModel.homeTotal, appTheme: appTheme)
                    .frame(width: columnWidth)

                Spacer().frame(width: horizontalPadding)

                GridPowerFooterView(importTotal: viewModel.gridImportTotal,
                                    exportTotal: viewModel.gridExportTotal,
                                    appTheme: appTheme)
                    .frame(width: columnWidth)
            }
            .padding(.bottom, 16)
            .padding(.horizontal, horizontalPadding)

        }.background(GeometryReader { reader in
            Color.clear.onAppear { size = reader.size }.onChange(of: reader.size) { newValue in size = newValue }
        })
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }

    private let horizontalPadding: CGFloat = 14
    private var columnWidth: CGFloat {
        let spacerCount: CGFloat = 3 + (showingBatteryColumn ? 1 : 0)
        return (UIScreen.main.bounds.width - (horizontalPadding * spacerCount)) / (showingBatteryColumn ? 3 : 2)
    }

    private var columnCount: CGFloat {
        showingBatteryColumn ? 3 : 2
    }

    private var inverterPadding: CGFloat {
        showingBatteryColumn ? 6 : 2
    }

    private var showingBatteryColumn: Bool {
        viewModel.hasBattery || viewModel.hasBatteryError
    }

    private var inverterLineWidth: CGFloat {
        let lineWidth: CGFloat = 4
        return columnWidth * (columnCount - 1) + (horizontalPadding * (columnCount - 1)) + (2.0 * (lineWidth / 2.0))
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFlowView(configManager: PreviewConfigManager(),
                          viewModel: HomePowerFlowViewModel.any(battery: .any()),
                          appThemePublisher: CurrentValueSubject(AppTheme.mock(decimalPlaces: 3, showInW: false, showInverterTemperature: true, showHomeTotalOnPowerFlow: true)))
            .environment(\.locale, .init(identifier: "de"))
    }
}

extension HomePowerFlowViewModel {
    static func any(battery: BatteryViewModel = .any()) -> HomePowerFlowViewModel {
        .init(solar: 2.5,
              battery: battery,
              home: 1.5,
              grid: 0.71,
              todaysGeneration: 8.5,
              earnings: "GBP(£) 1 / 5 / 99",
              inverterTemperatures: InverterTemperatures(ambient: 4.0, inverter: 9.0),
              homeTotal: 1.0,
              gridImportTotal: 12.0,
              gridExportTotal: 2.4)
    }
}

extension BatteryViewModel {
    static func any() -> BatteryViewModel {
        BatteryViewModel(
            hasBattery: true,
            chargeLevel: 0.99,
            chargePower: 0.1,
            temperature: 15.6,
            residual: 5678
        )
    }
}
