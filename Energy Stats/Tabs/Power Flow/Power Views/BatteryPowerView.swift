//
//  BatteryPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatteryPowerViewModel {
    private let actualBatteryStateOfCharge: Double
    private(set) var batteryChargekWh: Double
    private let calculator: BatteryCapacityCalculator
    private(set) var temperature: Double
    private let configManager: ConfigManaging
    let residual: Int
    let error: Error?

    init(configManager: ConfigManaging, batteryStateOfCharge: Double, batteryChargekWH: Double, temperature: Double, batteryResidual: Int, error: Error?) {
        actualBatteryStateOfCharge = batteryStateOfCharge
        batteryChargekWh = batteryChargekWH
        self.temperature = temperature
        self.configManager = configManager
        residual = batteryResidual
        self.error = error

        calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                               minimumSOC: configManager.minSOC)
    }

    var batteryExtra: String? {
        calculator.batteryChargeStatusDescription(
            batteryChargePowerkWH: batteryChargekWh,
            batteryStateOfCharge: actualBatteryStateOfCharge
        )
    }

    var batteryStoredChargekWh: Double {
        Double(residual) / 1000.0
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
}

struct BatteryPowerView: View {
    let viewModel: BatteryPowerViewModel
    let appTheme: AppTheme
    @State private var alertContent: AlertContent?

    var body: some View {
        ZStack {
            VStack {
                PowerFlowView(amount: viewModel.batteryChargekWh, appTheme: appTheme, showColouredLines: true, type: .batteryFlow)
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
                alertContent = AlertContent(title: String(key: .errorTitle),
                                            message: String(format: String(key: .batteryReadError), String(describing: viewModel.error)))
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

struct BatteryPowerView_Previews: PreviewProvider {
    struct FakeError: Error {}

    static var previews: some View {
        BatteryPowerView(viewModel: BatteryPowerViewModel.any(error: FakeError()),
                         appTheme: AppTheme.mock())
    }
}

extension BatteryPowerViewModel {
    static func any(error: Error?) -> BatteryPowerViewModel {
        .init(configManager: PreviewConfigManager(), batteryStateOfCharge: 0.99, batteryChargekWH: -0.01, temperature: 15.6, batteryResidual: 5940, error: error)
    }
}
