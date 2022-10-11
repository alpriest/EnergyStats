//
//  BatteryPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import SwiftUI

struct BatteryPowerViewModel {
    let batteryStateOfCharge: Double
    let battery: Double
    private let calculator: BatteryCapacityCalculator

    init(configManager: ConfigManager, batteryStateOfCharge: Double, battery: Double) {
        self.batteryStateOfCharge = batteryStateOfCharge
        self.battery = battery

        calculator = BatteryCapacityCalculator(capacitykW: configManager.batteryCapacity,
                                               minimumSOC: configManager.minSOC)
    }

    var batteryExtra: String? {
        calculator.batteryPercentageRemaining(batteryChargePowerkWH: battery, batteryStateOfCharge: batteryStateOfCharge)
    }

    var batteryCapacity: String {
        calculator.currentEstimatedChargeAmountkWH(batteryStateOfCharge: batteryStateOfCharge).kW()
    }
}

struct BatteryPowerView: View {
    let viewModel: BatteryPowerViewModel
    @Binding var iconFooterSize: CGSize
    @State private var percentage = true

    var body: some View {
        VStack {
            PowerFlowView(amount: viewModel.battery)
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 48))
                .background(Color(.systemBackground))
                .frame(width: 45, height: 45)
            VStack {
                Group {
                    if percentage {
                        Text(viewModel.batteryStateOfCharge, format: .percent)
                    } else {
                        Text(viewModel.batteryCapacity)
                    }
                }.onTapGesture {
                    percentage.toggle()
                }

                OptionalView(viewModel.batteryExtra) {
                    Text($0)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(Color.gray)
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
        BatteryPowerView(viewModel: BatteryPowerViewModel.any(), iconFooterSize: .constant(CGSize.zero))
    }
}

extension BatteryPowerViewModel {
    static func any() -> BatteryPowerViewModel {
        .init(configManager: MockConfigManager(), batteryStateOfCharge: 0.99, battery: -0.01)
    }
}
