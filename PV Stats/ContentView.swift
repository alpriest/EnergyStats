//
//  ContentView.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            if let report = viewModel.report {
                VStack {
                    PowerGraph(current: report.currentSolarPower, maximum: 4.0)
                    Text("Solar generation kWh")
                        .font(.caption2)
                }
            }

            if let battery = viewModel.battery {
                VStack {
                    CircularProgressView(progress: battery.chargeLevel)
                    Text("Battery level")
                }
            }

            Spacer()

            HStack {
                Text("Last updated ")
                Text(viewModel.lastUpdated)
            }
        }
        .padding()
        .onAppear {
            Task {
                try await viewModel.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(MockNetworking()))
    }
}

class MockNetworking: Networking {
    func fetch() async throws -> (ReportResponse, BatteryResponse) {
        let report = ReportResponse(result: [.init(variable: HistoryVariableKey.feedin(), data: [.init(index: 14, value: 1.5)])])
        let battery = BatteryResponse(errno: 0, result: .init(soc: 56))

        return (report, battery)
    }
}
