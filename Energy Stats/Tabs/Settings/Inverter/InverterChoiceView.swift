//
//  InverterChoiceView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import Energy_Stats_Core
import SwiftUI

class InverterChoiceViewModel: ObservableObject {
    #if OPEN_API
    @Published var selectedDeviceSN: String {
        didSet {
            configManager.select(deviceSN: selectedDeviceSN)
        }
    }
    #else
    @Published var selectedDeviceID: String {
        didSet {
            configManager.select(device: devices.first(where: { $0.deviceID == selectedDeviceID }))
        }
    }
    #endif

    @Published var devices: [Device]

    private let configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        #if OPEN_API
        self.selectedDeviceSN = configManager.selectedDeviceSN
        #else
        self.selectedDeviceID = configManager.selectedDeviceID ?? ""
        #endif
        self.devices = configManager.devices ?? []
    }
}

struct InverterChoiceView: View {
    @ObservedObject var viewModel: InverterChoiceViewModel

    var body: some View {
        if viewModel.devices.count > 1 {
            Section(
                content: {
                    #if OPEN_API
                    Picker("Inverter", selection: $viewModel.selectedDeviceSN) {
                        ForEach(viewModel.devices, id: \.deviceSN) { device in
                            Text(device.deviceSelectorName)
                                .tag(device.deviceSN)
                        }
                    }
                    #else
                    Picker("Inverter", selection: $viewModel.selectedDeviceID) {
                        ForEach(viewModel.devices, id: \.deviceID) { device in
                            Text(device.deviceSelectorName)
                                .tag(device.deviceID)
                        }
                    }
                    #endif
                },
                header: { Text("Device selection") },
                footer: { Text("Selected device and related battery information will be displayed on the main page") }
            )
        }
    }
}

struct InverterChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = InverterChoiceViewModel(
            configManager: PreviewConfigManager()
        )

        return Form {
            InverterChoiceView(viewModel: viewModel)
        }
    }
}
