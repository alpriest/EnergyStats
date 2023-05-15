//
//  ResponseDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ResponseDebugView<T: Decodable>: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkStore
    let title: String
    let missing: String
    let mapper: (InMemoryLoggingNetworkStore) -> NetworkOperation<T>?

    struct Line: Identifiable {
        let id = UUID()
        let text: String

        init(text: String.SubSequence) {
            self.text = String(text)
        }
    }

    var body: some View {
        VStack {
            if let response = mapper(network) {
                (Text("Last fetched ") +
                    Text(response.time, formatter: DateFormatter.forDebug()))
                    .padding(.bottom)

                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(lines) { line in
                            Text(line.text)
                        }
                    }
                    .font(.custom("Courier", size: 12.0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(missing)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
    }

    private var asText: String {
        guard let data = mapper(network)?.raw else { return "" }

        return data.formattedJSON()
    }

    private var lines: [Line] {
        asText.split(separator: "\n").map(Line.init)
    }
}

struct ResponseDebugView_Previews: PreviewProvider {
    static var previews: some View {
        let network = DemoNetworking()
        let store = InMemoryLoggingNetworkStore()
        Task {
            store.reportResponse = try NetworkOperation(description: "fetchReport", value: await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .current(), reportType: .day), raw: "Report is only fetched and cached on the graph view. Click that page to load report data\nClick that page to load report data".data(using: .utf8)!)
        }

        return ResponseDebugView<[ReportResponse]>(
            title: "Report",
            missing: "Data is only fetched and cached on the graph view.\nClick that page to load report data",
            mapper: { $0.reportResponse }
        )
        .environmentObject(store)
    }
}

extension Data {
    func formattedJSON() -> String {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        {
            return String(decoding: jsonData, as: UTF8.self)
        } else {
            assertionFailure("Malformed JSON")
        }

        return ""
    }
}
