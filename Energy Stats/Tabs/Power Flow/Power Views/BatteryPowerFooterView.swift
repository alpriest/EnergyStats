//
//  BatteryPowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryPowerFooterView: View {
    let viewModel: BatteryPowerViewModel
    let appSettings: AppSettings

    var body: some View {
        VStack {
            Group {
                if appSettings.showBatteryPercentageRemaining {
                    (Text(viewModel.batteryStateOfCharge, format: .percent) + Text(viewModel.showUsableBatteryOnly ? "*" : ""))
                        .accessibilityLabel(String(format: String(accessibilityKey: .batteryCapacityPercentage), String(describing: viewModel.batteryStateOfCharge.percent())))
                } else {
                    EnergyText(amount: viewModel.batteryStoredChargekWh, appSettings: appSettings, type: .batteryCapacity, suffix: viewModel.showUsableBatteryOnly ? "*" : "")
                }
            }.onTapGesture {
                viewModel.showBatteryPercentageRemainingToggle()
            }

            HStack {
                if appSettings.showBatteryTemperature {
                    ForEach(viewModel.temperatures, id: \.id) { temperature in
                        TemperatureView(
                            value: temperature.value,
                            name: temperature.name,
                            accessibilityName: String(accessibilityKey: .batteryTemperature),
                            showName: viewModel.temperatures.count > 1
                        )
                    }
                }
            }

            if appSettings.showBatteryEstimate {
                OptionalView(viewModel.batteryExtra) {
                    (Text($0) + Text(viewModel.showUsableBatteryOnly ? "*" : ""))
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(Color("text_dimmed"))
                        .accessibilityLabel(String(format: String(accessibilityKey: .batteryEstimate), $0))
                }
            }
        }
        .opacity(viewModel.hasError ? 0.2 : 1.0)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let config = MockConfig()
    config.showUsableBatteryOnly = true
    return BatteryPowerFooterView(viewModel: BatteryPowerViewModel.any(error: nil, config: config),
                                  appSettings: AppSettings.mock())
}
