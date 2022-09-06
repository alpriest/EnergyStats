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
        VStack(spacing: 44) {
            HStack {
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
                        Text("Battery")
                            .font(.caption2)
                    }
                }
            }

            HStack {
                if let report = viewModel.report {
                    VStack {
                        HistoricalGraph(data: report.gridImport)
                        Text("Grid import kWh")
                            .font(.caption2)
                    }

                    VStack {
                        HistoricalGraph(data: report.gridExport)
                        Text("Grid export kWh")
                            .font(.caption2)
                    }
                }
            }
            .frame(height: 200)

            Spacer()

            HStack {
                Text("Last updated")
                Text(viewModel.lastUpdated)
            }
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(MockNetworking()))
    }
}

class MockNetworking: Networking {
    func fetchReport() async throws -> ReportResponse {
        ReportResponse(result: [.init(variable: HistoryVariableKey.feedin(), data: [.init(index: 14, value: 1.5)])])
    }

    func fetchBattery() async throws -> BatteryResponse {
        BatteryResponse(errno: 0, result: .init(soc: 56))
    }
}
