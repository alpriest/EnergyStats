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
                .frame(width: batteryPowerWidth + gridPowerWidth + (inverterPadding * 5))
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
                                     iconFooterHeight: $iconFooterHeight,
                                     appTheme: appTheme)
                        .background(GeometryReader { reader in
                            Color.clear
                                .onChange(of: reader.size) { batteryPowerWidth = $0.width }
                                .onAppear { batteryPowerWidth = reader.size.width }
                        })

                    Spacer()
                }

                HomePowerView(amount: viewModel.home, total: viewModel.homeTotal, iconFooterHeight: iconFooterHeight, appTheme: appTheme)
                    .background(GeometryReader { reader in
                        Color.clear
                            .onChange(of: reader.size) { homePowerWidth = $0.width }
                            .onAppear { homePowerWidth = reader.size.width }
                    })

                Spacer()

                GridPowerView(amount: viewModel.grid, gridExportTotal: viewModel.gridExportTotal, gridImportTotal: viewModel.gridImportTotal, iconFooterHeight: iconFooterHeight, appTheme: appTheme)
                    .background(GeometryReader { reader in
                        Color.clear
                            .onChange(of: reader.size) { gridPowerWidth = $0.width }
                            .onAppear { gridPowerWidth = reader.size.width }
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

    private var inverterPadding: CGFloat {
        (viewModel.hasBattery || viewModel.hasBatteryError) ? 4 : 2
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
