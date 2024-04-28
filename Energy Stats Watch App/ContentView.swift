//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    let deviceSN: String?
    let token: String?
    let network: Networking
    @State private var batterySOC: Double?

    var body: some View {
        VStack {
            Image(systemName: "minus.plus.batteryblock.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)

            if let batterySOC {
                Text("Battery \(batterySOC, format: .percent)")
            }
        }
        .task {
            Task { batterySOC = try? await loadData() }
        }
        .padding()
    }

    private func loadData() async throws -> Double? {
        guard let deviceSN else { return nil }

        let reals = try await network.fetchRealData(deviceSN: deviceSN,
                                                    variables: ["SoC", "SoC_1"])
        return reals.datas.SoC() / 100.0
    }
}

#Preview {
    ContentView(deviceSN: "abc", token: "123", network: DemoNetworking())
}
