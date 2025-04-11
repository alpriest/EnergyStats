//
//  DeviceSettingItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct DeviceSettingItemView: View {
    @StateObject var viewModel: DeviceSettingItemViewModel

    init(item: DeviceSettingsItem, networking: Networking, configManager: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: DeviceSettingItemViewModel(item: item, networking: networking, configManager: configManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    HStack {
                        Text(viewModel.title)
                        NumberTextField(viewModel.title, text: $viewModel.value)
                            .multilineTextAlignment(.trailing)
                        Text(viewModel.unit)
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(viewModel.description)
                        Text(viewModel.behaviour)

                        Text("These settings control the behaviour of the inverter. Please be cautious and only change them if you know what you are doing.")
                            .foregroundStyle(Color.red)

                        Text("Energy Stats cannot be held responsible for any damage caused by changing these settings.")
                            .foregroundStyle(Color.red)
                    }
                }
            }

            BottomButtonsView {
                viewModel.save()
            }
        }
        .loadable(viewModel.state, retry: { viewModel.load() })
    }
}

#Preview {
    DeviceSettingItemView(
        item: .exportLimit,
        networking: NetworkService.preview(),
        configManager: ConfigManager.preview()
    )
}
