//
//  LoadedPowerFlowView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct LoadedPowerFlowView: View {
    @State private var iconFooterHeight: Double = 0
    @State private var appSettings: AppSettings
    @State private var size: CGSize = .zero
    private let configManager: ConfigManaging
    @ObservedObject var viewModel: LoadedPowerFlowViewModel
    private var appSettingsPublisher: LatestAppSettingsPublisher
    @State private var showSchedule = false
    private let networking: Networking
    private let templateStore: TemplateStoring
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(
        configManager: ConfigManaging,
        viewModel: LoadedPowerFlowViewModel,
        appSettingsPublisher: LatestAppSettingsPublisher,
        networking: Networking,
        templateStore: TemplateStoring
    ) {
        self.configManager = configManager
        self.viewModel = viewModel
        self.networking = networking
        self.templateStore = templateStore
        self.appSettingsPublisher = appSettingsPublisher
        self._appSettings = State(wrappedValue: appSettingsPublisher.value)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 0) {
                if size == .zero {
                    Color.clear.frame(minWidth: 0, maxWidth: .infinity)
                } else {
                    if appSettings.showTotalYieldOnPowerFlow {
                        HStack(spacing: 0) {
                            (Text("Solar today") + Text(" ")).accessibilityHidden(true)

                            EnergyText(amount: viewModel.todaysGeneration?.todayGeneration() ?? 0, appSettings: appSettings, type: .totalYield, decimalPlaceOverride: 1)
                                .redactedShimmer(when: viewModel.todaysGeneration == nil)
                        }
                        .padding(.bottom, 8)
                    }

                    if appSettings.showFinancialSummaryOnFlowPage, let earnings = viewModel.earnings {
                        EarningsView(viewModel: earnings, appSettings: appSettings)
                            .padding(.bottom, 12)
                    }

                    ZStack {
                        HStack {
                            if appSettings.ct2DisplayMode == .separateIcon {
                                VStack(spacing: 0) {
                                    CT2_icon()
                                    PowerFlowView(amount: viewModel.ct2, appSettings: appSettings, showColouredLines: false, type: .solarFlowCT2)
                                    Color.clear.frame(height: size.height * 0.073)
                                }
                                .frame(width: topColumnWidth, height: size.height * 0.35)

                                Spacer().frame(width: horizontalPadding)
                            }

                            SolarPowerView(appSettings: appSettings, viewModel: SolarPowerViewModel(solar: viewModel.solar))
                                .overlay(
                                    SolarStringsView(viewModel: viewModel, appSettings: appSettings)
                                        .offset(x: 0, y: -40)
                                )
                                .frame(width: topColumnWidth, height: size.height * 0.40)
                                .overlay(
                                    Group {
                                        if !appSettings.shouldCombineCT2WithPVPower && appSettings.ct2DisplayMode == .separateIcon {
                                            PowerAmountView(amount: viewModel.solar + viewModel.ct2, backgroundColor: .linesNotFlowing, textColor: .textNotFlowing, appSettings: appSettings, type: .solarFlow)
                                                .font(.body.bold())
                                                .offset(x: 0, y: 100)
                                        }
                                    }
                                )

                            if appSettings.ct2DisplayMode == .separateIcon {
                                Spacer().frame(width: horizontalPadding)

                                Color.clear
                                    .frame(width: topColumnWidth, height: size.height * 0.35)
                            }
                        }

                        if appSettings.ct2DisplayMode == .separateIcon {
                            PowerFlowView(amount: viewModel.ct2, appSettings: appSettings, showColouredLines: false, type: .solarFlow, shape: MidYHorizontalLine(), showAmount: false)
                                .offset(x: -0.5 * topColumnWidth - (horizontalPadding / 2.0), y: size.height * 0.1)
                                .frame(width: topColumnWidth + horizontalPadding)
                        }
                    }

                    InverterView(
                        viewModel: InverterViewModel(
                            configManager: configManager,
                            temperatures: viewModel.inverterTemperatures,
                            deviceState: viewModel.deviceState,
                            faults: viewModel.faults
                        ),
                        appSettings: appSettings
                    )
                    .frame(height: 2)
                    .frame(width: inverterLineWidth)
                    .padding(.vertical, 1)
                    .zIndex(1)

                    HStack(alignment: .top) {
                        if viewModel.hasBattery || viewModel.hasBatteryError {
                            BatteryPowerView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                              batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                              batteryChargekWH: viewModel.battery,
                                                                              temperatures: viewModel.batteryTemperatures,
                                                                              batteryResidual: viewModel.batteryResidual,
                                                                              error: viewModel.batteryError,
                                                                              minSOC: appSettings.minSOC),
                                             appSettings: appSettings)
                                .frame(width: bottomColumnWidth)

                            Spacer().frame(width: horizontalPadding)
                        }

                        HomePowerView(amount: viewModel.home, appSettings: appSettings)
                            .frame(width: bottomColumnWidth)

                        Spacer().frame(width: horizontalPadding)

                        GridPowerView(amount: viewModel.grid, appSettings: appSettings)
                            .frame(width: bottomColumnWidth)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal, horizontalPadding)

                    // Totals
                    HStack(alignment: .top) {
                        if viewModel.hasBattery || viewModel.hasBatteryError {
                            BatteryPowerFooterView(viewModel: BatteryPowerViewModel(configManager: configManager,
                                                                                    batteryStateOfCharge: viewModel.batteryStateOfCharge,
                                                                                    batteryChargekWH: viewModel.battery,
                                                                                    temperatures: viewModel.batteryTemperatures,
                                                                                    batteryResidual: viewModel.batteryResidual,
                                                                                    error: viewModel.batteryError,
                                                                                    minSOC: appSettings.minSOC),
                                                   appSettings: appSettings)
                                .frame(width: bottomColumnWidth)

                            Spacer().frame(width: horizontalPadding)
                        }

                        HomePowerFooterView(amount: viewModel.homeTotal, appSettings: appSettings)
                            .frame(width: bottomColumnWidth)

                        Spacer().frame(width: horizontalPadding)

                        GridPowerFooterView(importTotal: viewModel.gridImportTotal,
                                            exportTotal: viewModel.gridExportTotal,
                                            appSettings: appSettings)
                            .frame(width: bottomColumnWidth)
                    }
                    .padding(.bottom, verticalSizeClass == .regular ? 16 : 4)
                    .padding(.horizontal, horizontalPadding)
                }

            }.background(GeometryReader { reader in
                Color.clear.onAppear { size = reader.size }.onChange(of: reader.size) { newValue in size = newValue }
            })

            inverterScheduleQuickLink()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
        .sheet(isPresented: $showSchedule) {
            NavigationStack {
                ScheduleSummaryView(
                    networking: networking,
                    config: configManager,
                    templateStore: templateStore
                )
            }
        }
    }

    @ViewBuilder
    private func inverterScheduleQuickLink() -> some View {
        if appSettings.showInverterScheduleQuickLink {
            Button {
                showSchedule.toggle()
            } label: {
                Image(systemName: "calendar")
                    .padding(.horizontal)
            }
        }
    }

    private let horizontalPadding: CGFloat = 14
    private var bottomColumnWidth: CGFloat {
        let spacerCount: CGFloat = 3 + (showingBatteryColumn ? 1 : 0)
        return (width - (horizontalPadding * spacerCount)) / (showingBatteryColumn ? 3 : 2)
    }

    private var topColumnWidth: CGFloat {
        let spacerCount: CGFloat = 4
        return (width - (horizontalPadding * spacerCount)) / (showingCT2Column ? 2.8 : 2)
    }

    private var width: Double {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            return window.frame.size.width
        } else {
            return UIScreen.main.bounds.width
        }
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

    private var showingCT2Column: Bool {
        appSettings.ct2DisplayMode == .separateIcon
    }

    private var inverterLineWidth: CGFloat {
        let lineWidth: CGFloat = 4
        return bottomColumnWidth * (columnCount - 1) + (horizontalPadding * (columnCount - 1)) + (2.0 * (lineWidth / 2.0))
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static let strings = PowerFlowStringsSettings.none.copy(enabled: true, pv1Name: "Front", pv2Name: "Rear")
    static var previews: some View {
        let appSettings = AppSettings.mock().copy(powerFlowStrings: PowerFlowStringsSettings.none.copy(enabled: true, pv1Name: "Front", pv2Name: "To"))

        LoadedPowerFlowView(configManager: ConfigManager.preview(),
                            viewModel: LoadedPowerFlowViewModel.any(battery: .any(), appSettings: appSettings),
                            appSettingsPublisher: CurrentValueSubject(appSettings.copy(decimalPlaces: 3,
                                                                                              displayUnit: .adaptive,
                                                                                              showFinancialEarnings: true,
                                                                                              showInverterTemperature: true,
                                                                                              showHomeTotalOnPowerFlow: true,
                                                                                              shouldCombineCT2WithPVPower: true,
                                                                                              powerFlowStrings: strings)),
                            networking: NetworkService.preview(),
                            templateStore: TemplateStore.preview())
            .environment(\.locale, .init(identifier: "en"))
    }
}
