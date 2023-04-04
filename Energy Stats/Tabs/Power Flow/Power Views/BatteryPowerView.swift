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
    private(set) var batteryChargekWH: Double
    private let calculator: BatteryCapacityCalculator
    private(set) var temperature: Double
    private let configManager: ConfigManaging

    init(configManager: ConfigManaging, batteryStateOfCharge: Double, batteryChargekWH: Double, temperature: Double) {
        self.actualBatteryStateOfCharge = batteryStateOfCharge
        self.batteryChargekWH = batteryChargekWH
        self.temperature = temperature
        self.configManager = configManager

        calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                               minimumSOC: configManager.minSOC)
    }

    var batteryExtra: String? {
        calculator.batteryChargeStatusDescription(
            batteryChargePowerkWH: batteryChargekWH,
            batteryStateOfCharge: batteryStateOfCharge
        )
    }

    var batteryStoredChargekW: Double {
        calculator.currentEstimatedChargeAmountW(
            batteryStateOfCharge: actualBatteryStateOfCharge,
            includeUnusableCapacity: !configManager.showUsableBatteryOnly
        ) / 1000.0
    }

    var batteryStateOfCharge: Double {
        calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: actualBatteryStateOfCharge, includeUnusableCapacity: !configManager.showUsableBatteryOnly)
    }
}

struct BatteryPowerView: View {
    let viewModel: BatteryPowerViewModel
    @Binding var iconFooterSize: CGSize
    @State private var percentage = true
    let appTheme: LatestAppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: viewModel.batteryChargekWH, appTheme: appTheme, showColouredLines: true)
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 48))
                .background(Color(.systemBackground))
                .frame(width: 45, height: 45)
            VStack {
                Group {
                    if percentage {
                        Text(viewModel.batteryStateOfCharge, format: .percent)
                    } else {
                        Text(viewModel.batteryStoredChargekW.kW(appTheme.value.decimalPlaces))
                    }
                }.onTapGesture {
                    percentage.toggle()
                }

                if appTheme.value.showBatteryTemperature {
                    Text(viewModel.temperature, format: .number) + Text("°C")
                }

                if appTheme.value.showBatteryEstimate {
                    OptionalView(viewModel.batteryExtra) {
                        Text($0)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                }
            }
            .background(GeometryReader { reader in
                Color.clear.preference(key: BatterySizePreferenceKey.self, value: reader.size)
                    .onPreferenceChange(BatterySizePreferenceKey.self) { size in
                        iconFooterSize = size
                    }
            })
        }
    }
}

struct BatteryPowerView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryPowerView(viewModel: BatteryPowerViewModel.any(), iconFooterSize: .constant(CGSize.zero),
                         appTheme: CurrentValueSubject(AppTheme.mock()))
    }
}

extension BatteryPowerViewModel {
    static func any() -> BatteryPowerViewModel {
        .init(configManager: PreviewConfigManager(), batteryStateOfCharge: 0.99, batteryChargekWH: -0.01, temperature: 15.6)
    }
}
