//
//  BatteryPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

class BatteryPowerViewModel {
    private let actualBatteryStateOfCharge: Double
    private(set) var batteryChargekWh: Double
    private(set) var temperature: Double
    private var configManager: ConfigManaging
    let residual: Int
    let error: Error?
    private let minSOC: Double

    init(configManager: ConfigManaging, batteryStateOfCharge: Double, batteryChargekWH: Double, temperature: Double, batteryResidual: Int, error: Error?, minSOC: Double) {
        actualBatteryStateOfCharge = batteryStateOfCharge
        batteryChargekWh = batteryChargekWH
        self.temperature = temperature
        self.configManager = configManager
        residual = batteryResidual
        self.error = error
        self.minSOC = minSOC
    }

    var batteryExtra: String? {
        calculator.batteryChargeStatusDescription(
            batteryChargePowerkW: batteryChargekWh,
            batteryStateOfCharge: actualBatteryStateOfCharge
        )
    }

    var batteryStoredChargekWh: Double {
        calculator.currentEstimatedChargeAmountWh(batteryStateOfCharge: actualBatteryStateOfCharge, includeUnusableCapacity: !configManager.showUsableBatteryOnly) / 1000.0
    }

    var batteryStateOfCharge: Double {
        calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: actualBatteryStateOfCharge, includeUnusableCapacity: !configManager.showUsableBatteryOnly)
    }

    var hasBattery: Bool {
        configManager.hasBattery
    }

    var hasError: Bool {
        error != nil
    }

    func showBatteryPercentageRemainingToggle() {
        configManager.showBatteryPercentageRemaining.toggle()
    }

    var showUsableBatteryOnly: Bool {
        configManager.showUsableBatteryOnly
    }

    var calculator: BatteryCapacityCalculator {
        BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                  minimumSOC: minSOC)
    }
}

struct BatteryPowerView: View {
    let viewModel: BatteryPowerViewModel
    let appSettings: AppSettings
    @State private var alertContent: AlertContent?

    var body: some View {
        ZStack {
            VStack {
                PowerFlowView(amount: viewModel.batteryChargekWh, appSettings: appSettings, showColouredLines: true, type: .batteryFlow)
                    .opacity(viewModel.hasError ? 0.2 : 1.0)

                Image(systemName: "minus.plus.batteryblock.fill")
                    .font(.system(size: 48))
                    .frame(width: 45, height: 45)
                    .accessibilityHidden(true)
                    .opacity(viewModel.hasError ? 0.2 : 1.0)
            }

            if viewModel.hasError {
                errorOverlay()
            }
        }
    }

    @ViewBuilder
    func errorOverlay() -> some View {
        if viewModel.hasError {
            Button {
                alertContent = AlertContent(title: "error_title",
                                            message: LocalizedStringKey(stringLiteral: String(format: String(key: .batteryReadError), String(describing: viewModel.error))))
            } label: {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.linesNegative)

                    Text("Battery error. Tap for detail")
                }.buttonStyle(.plain)
            }
            .font(.caption)
            .alert(alertContent: $alertContent)
        }
    }
}

#Preview {
    struct FakeError: Error {}

    return BatteryPowerView(
        viewModel: BatteryPowerViewModel.any(error: nil),
        appSettings: AppSettings.mock()
            .copy(showBatteryEstimate: true)
            .copy(showUsableBatteryOnly: true)
    )
}

extension BatteryPowerViewModel {
    static func any(error: Error?, config: Config = MockConfig()) -> BatteryPowerViewModel {
        .init(
            configManager: ConfigManager.preview(config: config),
            batteryStateOfCharge: 0.99,
            batteryChargekWH: -0.01,
            temperature: 15.6,
            batteryResidual: 5940,
            error: error,
            minSOC: 0.2
        )
    }
}
