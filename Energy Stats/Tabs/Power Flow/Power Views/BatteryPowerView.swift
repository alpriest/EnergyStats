//
//  BatteryPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import SwiftUI

struct BatteryPowerView: View {
    let viewModel: HomePowerFlowViewModel
    @Binding var iconFooterSize: CGSize

    var body: some View {
        VStack {
            PowerFlowView(amount: viewModel.battery)
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 48))
                .background(Color(.systemBackground))
                .frame(width: 45, height: 45)
            VStack {
                Text(viewModel.batteryStateOfCharge, format: .percent)
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
        BatteryPowerView(viewModel: HomePowerFlowViewModel.any(), iconFooterSize: .constant(CGSize.zero))
    }
}
