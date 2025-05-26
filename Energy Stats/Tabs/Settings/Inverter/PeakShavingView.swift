//
//  PeakShavingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/05/2025.
//

import Energy_Stats_Core
import SwiftUI

class PeakShavingViewModel: ObservableObject, HasLoadState {
    let networking: Networking
    let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var importLimit: SettingItem?
    @Published var soc: SettingItem?

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchPeakShavingSettings(deviceSN: deviceSN)

                self.importLimit = settings.importLimit
                self.soc = settings.soc

                await setState(.inactive)
            } catch {
                if case NetworkError.foxServerError(40257, "") = error {
                    await setState(.inactive)
                } else {
                    await setState(.error(error, "Could not load settings"))
                }
            }
        }
    }
}

struct PeakShavingView: View {
    @StateObject var viewModel: PeakShavingViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: PeakShavingViewModel(networking: networking, config: config))
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    if let importLimit = viewModel.importLimit {
                        SettingItemView(
                            name: "Import limit",
                            item: importLimit,
                            onChange: { _ in }
                        )
                    }

                    if let soc = viewModel.soc {
                        SettingItemView(
                            name: "Threshold SOC",
                            item: soc,
                            onChange: { _ in }
                        )
                    }
                }
            } footer: {
                Text("When peak shaving is enabled, the system monitors the power being imported from the grid. If the import exceeds a predefined Import Limit, the system discharges the battery to supply the excess demand, thereby “shaving” the peak load from the grid. This operation continues as long as the battery’s state of charge (SOC) is above a certain Threshold SOC.")
            }
        }
        .navigationTitle(.peakShaving)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
    }
}

#Preview {
    PeakShavingView(networking: NetworkService.preview(),
                    config: ConfigManager.preview())
}
