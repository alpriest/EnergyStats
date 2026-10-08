//
//  InverterChoiceView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import Energy_Stats_Core
import SwiftUI

@Observable
class InverterChoiceViewModel {
    var selectedDeviceSN: String {
        didSet {
            configManager.select(device: devices.first(where: { $0.deviceSN == selectedDeviceSN }))
        }
    }

    var devices: [Device]

    private let configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        self.selectedDeviceSN = configManager.selectedDeviceSN ?? ""
        self.devices = configManager.devices ?? []
    }
}

struct InverterChoiceView: View {
    @State var viewModel: InverterChoiceViewModel
    
    init(configManager: ConfigManaging) {
        self._viewModel = .init(initialValue: InverterChoiceViewModel(configManager: configManager))
    }

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
                },
                header: { Text("Device selection") },
                footer: { Text("Selected device and related battery information will be displayed on the main page") }
            )
        }
    }
}

struct InverterChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            InverterChoiceView(configManager: ConfigManager.preview())
        }
    }
}
