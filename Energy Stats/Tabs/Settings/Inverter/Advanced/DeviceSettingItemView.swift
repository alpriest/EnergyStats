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
                        NumberTextField(viewModel.title, text: $viewModel.viewData.value)
                            .multilineTextAlignment(.trailing)
                        Text(viewModel.viewData.unit)
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(viewModel.description)
                        Text(viewModel.behaviour)

                        Text("Please be cautious and only change this setting if you know what you are doing.")
                            .foregroundStyle(Color.red)

                        Text("Energy Stats cannot be held responsible for any damage caused by changing this.")
                            .foregroundStyle(Color.red)
                    }
                }
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    DeviceSettingItemView(
        item: .maxSoc,
        networking: NetworkService.preview(),
        configManager: ConfigManager.preview()
    )
}
