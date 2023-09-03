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
    let appTheme: AppTheme

    var body: some View {
        VStack {
            Group {
                if batteryResidual {
                    EnergyText(amount: viewModel.batteryStoredChargekWh, appTheme: appTheme, type: .batteryCapacity)
                } else {
                    Text(viewModel.batteryStateOfCharge, format: .percent)
                        .accessibilityLabel(String(format: String(accessibilityKey: .batteryCapacityPercentage), String(describing: viewModel.batteryStateOfCharge.percent())))
                }
            }.onTapGesture {
                batteryResidual.toggle()
            }

            if appTheme.showBatteryTemperature {
                (Text(viewModel.temperature, format: .number) + Text("°C"))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(format: String(accessibilityKey: .batteryTemperature), viewModel.temperature.roundedToString(decimalPlaces: 2)))
            }

            if appTheme.showBatteryEstimate {
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
    }
}

struct BatteryPowerFooterView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryPowerFooterView(viewModel: BatteryPowerViewModel.any(error: nil),
                               appTheme: AppTheme.mock())
    }
}
