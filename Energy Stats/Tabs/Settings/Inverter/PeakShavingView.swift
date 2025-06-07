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
    @Published var importLimit: String = ""
    @Published var soc: String = ""
    @Published var supported = false

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

                self.importLimit = settings.importLimit.value.removingEmptyDecimals()
                self.soc = settings.soc.value
                self.supported = true

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
        VStack(spacing: 0) {
            Form {
                if viewModel.supported {
                    Section {
                        VStack {
                            HStack {
                                Text("Import limit")
                                Spacer()
                                NumberTextField("Import limit", text: $viewModel.importLimit)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                Text("kW")
                                    .frame(width: 30)
                            }

                            HStack {
                                Text("Battery threshold SOC")
                                Spacer()
                                NumberTextField("Battery threshold SOC", text: $viewModel.soc)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                Text("%")
                                    .frame(width: 30)
                            }
                        }
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("Your system monitors the power being imported from the grid. If the import exceeds your Import Limit of \(viewModel.importLimit) and your battery's state of charge (SOC) is above \(viewModel.soc)%, the system discharges the battery to supply the excess demand, thereby “shaving” the peak load from the grid.\n\nThis operation continues as long as the battery’s state of charge (SOC) is above a certain threshold SOC.\n\nPeak shaving only operates when you have the Peak Shaving mode enabled from the Inverter scheduler.")
                        }
                    }
                } else {
                    Text("Peak shaving is not available. This could be due to your inverter firmware or model.\n\nPlease contact FoxESS for further information.")
                }
            }

            BottomButtonsView {
                // TODO:
            }
        }
        .navigationTitle(.peakShaving)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
    }
}

#Preview {
    NavigationStack {
        PeakShavingView(networking: NetworkService.preview(),
                        config: ConfigManager.preview())
    }
}
