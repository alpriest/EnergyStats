//
//  BatteryPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatterySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct BatteryPowerViewModel {
    private let actualBatteryStateOfCharge: Double
    private(set) var batteryChargekWh: Double
    private let calculator: BatteryCapacityCalculator
    private(set) var temperature: Double
    private let configManager: ConfigManaging
    let residual: Double

    init(configManager: ConfigManaging, batteryStateOfCharge: Double, batteryChargekWH: Double, temperature: Double, batteryResidual: Double) {
        actualBatteryStateOfCharge = batteryStateOfCharge
        self.batteryChargekWh = batteryChargekWH
        self.temperature = temperature
        self.configManager = configManager
        self.residual = batteryResidual

        calculator = BatteryCapacityCalculator(capacityWh: configManager.batteryCapacityW,
                                               minimumSOC: configManager.minSOC)
    }

    var batteryExtra: String? {
        calculator.batteryChargeStatusDescription(
            batteryChargePowerkWH: batteryChargekWh,
            batteryStateOfCharge: actualBatteryStateOfCharge
        )
    }

    var batteryStoredChargekWh: Double {
        residual / 1000.0
    }

    var batteryStateOfCharge: Double {
        calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: actualBatteryStateOfCharge, includeUnusableCapacity: !configManager.showUsableBatteryOnly)
    }

    var hasBattery: Bool {
        configManager.hasBattery
    }
}

struct BatteryPowerView: View {
    let viewModel: BatteryPowerViewModel
    @Binding var iconFooterSize: CGSize
    @AppStorage("showBatteryAsResidual") private var batteryResidual: Bool = false
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: viewModel.batteryChargekWh, appTheme: appTheme, showColouredLines: true)
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 48))
                .frame(width: 45, height: 45)
            VStack {
                Group {
                    if batteryResidual {
                        EnergyText(amount: viewModel.batteryStoredChargekWh, appTheme: appTheme)
                    } else {
                        Text(viewModel.batteryStateOfCharge, format: .percent)
                    }
                }.onTapGesture {
                    batteryResidual.toggle()
                }

                if appTheme.showBatteryTemperature {
                    Text(viewModel.temperature, format: .number) + Text("°C")
                }

                if appTheme.showBatteryEstimate {
                    OptionalView(viewModel.batteryExtra) {
                        Text($0)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(Color("text_dimmed"))
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
                         appTheme: AppTheme.mock())
    }
}

extension BatteryPowerViewModel {
    static func any() -> BatteryPowerViewModel {
        .init(configManager: PreviewConfigManager(), batteryStateOfCharge: 0.99, batteryChargekWH: -0.01, temperature: 15.6, batteryResidual: 5940)
    }
}
