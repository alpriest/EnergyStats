//
//  BatteryPowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryPowerFooterView: View {
    @AppStorage("showBatteryAsResidual") private var batteryResidual: Bool = false
    let viewModel: BatteryPowerViewModel
    let appSettings: AppSettings

    var body: some View {
        VStack {
            Group {
                if batteryResidual {
                    EnergyText(amount: viewModel.batteryStoredChargekWh, appSettings: appSettings, type: .batteryCapacity)
                } else {
                    Text(viewModel.batteryStateOfCharge, format: .percent)
                        .accessibilityLabel(String(format: String(accessibilityKey: .batteryCapacityPercentage), String(describing: viewModel.batteryStateOfCharge.percent())))
                }
            }.onTapGesture {
                batteryResidual.toggle()
            }

            if appSettings.showBatteryTemperature {
                (Text(viewModel.temperature, format: .number) + Text("°C"))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(format: String(accessibilityKey: .batteryTemperature), viewModel.temperature.roundedToString(decimalPlaces: 2)))
            }

            if appSettings.showBatteryEstimate {
                OptionalView(viewModel.batteryExtra) {
                    Text($0)
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
    BatteryPowerFooterView(viewModel: BatteryPowerViewModel.any(error: nil),
                           appSettings: AppSettings.mock())
}
