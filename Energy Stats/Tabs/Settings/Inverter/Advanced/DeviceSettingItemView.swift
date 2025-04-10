//
//  DeviceSettingItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import Energy_Stats_Core
import SwiftUI

class DeviceSettingItemViewModel: ObservableObject, HasLoadState {
    private let item: DeviceSettingsItem
    private let networking: Networking
    private let config: ConfigManaging
    var title: String { item.title }
    var description: String { item.description }
    var behaviour: String { item.behaviour }
    @Published var value: String = ""
    @Published var unit: String = ""
    @Published var state = LoadState.inactive

    init(item: DeviceSettingsItem, networking: Networking, config: ConfigManaging) {
        self.item = item
        self.config = config
        self.networking = networking

        load()
    }

    func load() {
        guard state == .inactive else { return }

        Task {
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active("Loading"))

            do {
                let item = try await networking.fetchDeviceSettingsItem(item, deviceSN: deviceSN)

                Task { @MainActor in
                    self.value = item.value
                    self.unit = item.unit
                }

                await setState(.inactive)
            } catch {
                state = .error(error, "Could not fetch setting")
            }
        }
    }
}

struct DeviceSettingItemView: View {
    @StateObject var viewModel: DeviceSettingItemViewModel

    init(item: DeviceSettingsItem, networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: DeviceSettingItemViewModel(item: item, networking: networking, config: config))
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
                    }
                }
            }

            BottomButtonsView {
                // TODO:
            }
        }
        .loadable(viewModel.state, retry: { viewModel.load() } )
    }
}

#Preview {
    DeviceSettingItemView(item: .exportLimit, networking: NetworkService.preview(), config: ConfigManager.preview())
}
