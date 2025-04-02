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
                    Text("SN: \(module.batterySN)")
                        .font(.headline)
                    HStack {
                        Text("Type: \(module.type)")
                        Spacer()
                        Text("Version: \(module.version)")
                    }
                    .font(.subheadline)
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
}

#Preview {
    BatteryFirmwareVersionsView(network: NetworkService.preview(), config: ConfigManager.preview())
}
