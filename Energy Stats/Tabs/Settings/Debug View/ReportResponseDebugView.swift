//
//  ReportResponseDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ReportResponseDebugView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkingDecorator

    var body: some View {
        ScrollView {
            if let response = network.reportResponse {
                Text("Last fetched ") +
                Text(response.time, formatter: DateFormatter.forDebug())

                ForEach(response.data, id: \.self) { response in
                    VStack(alignment: .leading) {
                        Text(response.variable)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(response.data, id: \.self) {
                                Text($0.index, format: .number)
                                Text($0.value, format: .number)
                            }
                        }
                    }
                }.padding()
            } else {
                Text("Report is only fetched and cached on the graph view. Click that page to load report data")
            }
        }
        .navigationTitle("Report")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
    }

    private var asText: String {
        network.reportResponse?.data.flatMap { response in
            [response.variable] +
                response.data.map {
                    """
                    Time: \($0.index) Value: \($0.value)
                    """
                }
        }.joined(separator: "\n") ?? ""
    }
}

struct ReportResponseDebugView_Previews: PreviewProvider {
    static var previews: some View {
        let network = InMemoryLoggingNetworkingDecorator(inner: DemoNetworking())
        Task { try await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .current()) }

        return Form {
            ReportResponseDebugView()
                .environmentObject(network)
        }
    }
}
