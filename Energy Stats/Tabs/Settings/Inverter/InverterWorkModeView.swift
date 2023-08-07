//
//  InverterWorkModeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import Energy_Stats_Core
import SwiftUI

class InverterWorkModeViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var workMode: WorkMode = .selfUse

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task {
            guard state == .inactive else { return }
            guard let deviceID = config.currentDevice.value?.deviceID else { return }
            state = .active(String(key: .loading))

            do {
                // https://www.foxesscloud.com/c/v0/device/setting/get?id=03274209-486c-4ea3-9c28-159f25ee84cb&hasVersionHead=1&key=operation_mode__work_mode
                let response = try await networking.fetchWorkMode(deviceID: deviceID)
                workMode = response.values.operationModeWorkMode.asWorkMode()

                state = .inactive
            } catch {
                state = .error(error, "Could not load settings")
            }
        }
    }

    func save() {}
}

struct InverterWorkModeView: View {
    @StateObject var viewModel: InverterWorkModeViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: InverterWorkModeViewModel(networking: networking, config: config))
    }

    var body: some View {
        SingleSelectView(SingleSelectableListViewModel([WorkMode.selfUse],
                                                       allItems: WorkMode.allCases,
                                                       onApply: { _ in }),
                         header: {
                             HStack {
                                 Image(systemName: "exclamationmark.triangle.fill")
                                     .font(.title)
                                     .foregroundColor(.red)

                                 Text("Only change these values if you know what you are doing")

                                 Image(systemName: "exclamationmark.triangle.fill")
                                     .font(.title)
                                     .foregroundColor(.red)
                             }
                             .padding(.vertical)
                         }, footer: {
                             Link(destination: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Inverter-Work-Modes")!) {
                                 HStack {
                                     Text("Find out more about work modes")
                                     Image(systemName: "rectangle.portrait.and.arrow.right")
                                 }
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .font(.caption)
                             }
                         })
                         .navigationTitle("Configure Work Mode")
                         .navigationBarTitleDisplayMode(.inline)
                         .loadable($viewModel.state) {
                             viewModel.load()
                         }
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView(networking: DemoNetworking(), config: PreviewConfigManager())
        }
    }
}
