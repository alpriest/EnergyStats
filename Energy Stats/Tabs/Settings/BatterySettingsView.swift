//
//  BatterySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatterySettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @FocusState private var focused
    @State private var isEditingCapacity = false

    var body: some View {
        Section(
            content: {
                HStack {
                    Text("Min battery charge (SOC)")
                    Spacer()
                    Text(viewModel.minSOC, format: .percent)
                }

                HStack(alignment: .top) {
                    Text("Capacity")
                    Spacer()
                    HStack(alignment: .top) {
                        if isEditingCapacity {
                            VStack(alignment: .trailing) {
                                TextField("Capacity", text: $viewModel.batteryCapacity)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focused)

                                HStack {
                                    Button("OK") {
                                        isEditingCapacity = false
                                        focused = false
                                    }.buttonStyle(.bordered)
                                    Button("Cancel") {
                                        isEditingCapacity = false
                                        focused = false
                                    }.buttonStyle(.bordered)
                                }
                            }
                        } else {
                            Text(viewModel.batteryCapacity)
                                .onTapGesture {
                                    focused = true
                                    isEditingCapacity = true
                                }
                        }
                        Text(" W")
                    }
                }

            }, header: {
                Text("Battery")
            }, footer: {
                Text("capacity = residual / (Min SOC / 100)").italic() +
                    Text(" where residual is estimated by your installation and may not be accurate. Tap the capacity above to enter a manual value.\n\n") +
                    Text("Empty/full battery durations are estimates based on calculated capacity, assume that solar conditions and battery charge rates remain constant.")
            })
    }
}

struct BatterySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            BatterySettingsView(viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: PreviewConfigManager())
            )
        }
    }
}
