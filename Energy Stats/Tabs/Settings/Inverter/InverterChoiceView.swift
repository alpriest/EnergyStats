//
//  InverterChoiceView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import Energy_Stats_Core
import SwiftUI

class InverterChoiceViewModel: ObservableObject {
    @Published var selectedDeviceSN: String {
        didSet {
            configManager.select(deviceSN: selectedDeviceSN)
        }
    }

//    @Published var selectedDeviceID: String {
//        didSet {
//            configManager.select(device: devices.first(where: { $0.deviceID == selectedDeviceID }))
//        }
//    }

    @Published var devices: [Device]

    private let configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        self.selectedDeviceSN = configManager.selectedDeviceSN ?? ""
//        self.selectedDeviceID = configManager.selectedDeviceID ?? ""
        self.devices = [] // TODO
    }
}

struct InverterChoiceView: View {
    @ObservedObject var viewModel: InverterChoiceViewModel

    var body: some View {
        if viewModel.devices.count > 1 {
            Section(
                content: {
                    Picker("Inverter", selection: $viewModel.selectedDeviceSN) {
                        ForEach(viewModel.devices, id: \.deviceSN) { device in
                            Text(device.deviceSelectorName)
                                .tag(device.deviceSN)
                        }
                    }

//                    Picker("Inverter", selection: $viewModel.selectedDeviceID) {
//                        ForEach(viewModel.devices, id: \.deviceID) { device in
//                            Text(device.deviceSelectorName)
//                                .tag(device.deviceID)
//                        }
//                    }
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
