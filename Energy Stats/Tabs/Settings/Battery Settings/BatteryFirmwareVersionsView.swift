//
//  BatteryFirmwareVersionsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryFirmwareVersionsView: View {
    @StateObject var viewModel: BatteryFirmwareVersionsViewModel

    init(network: Networking, config: ConfigManaging) {
        self._viewModel = StateObject(wrappedValue: BatteryFirmwareVersionsViewModel(network: network, config: config))
    }

    var body: some View {
        Group {
            if viewModel.modules.isEmpty {
                Text("No battery information available")
            }

            List(viewModel.modules) { module in
                VStack(alignment: .leading) {
                    labelled(title: "SN", value: module.batterySN)
                        .font(.headline)

                    HStack {
                        labelled(title: String(localized: "Type"), value: module.type)
                        Spacer()
                        labelled(title: String(localized: "Version"), value: module.version)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            Task { await self.viewModel.load() }
        }
        .navigationTitle("Batteries")
        .loadable(viewModel.state, retry: { Task { await viewModel.load() } })
    }

    private func labelled(title: String, value: String) -> some View {
        Text(title.localised()) + Text(": ") + Text(value)
    }
}

#Preview {
    BatteryFirmwareVersionsView(
        network: NetworkService.preview(),
        config: ConfigManager.preview()
    )
}
