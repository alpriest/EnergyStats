//
//  ResponseDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ResponseDebugView<T: Decodable>: View {
    let title: String
    let missing: String
    let fetcher: (() async throws -> ())?
    private let store: InMemoryLoggingNetworkStore
    @State private var fetchError: String?
    @State private var mapResult: NetworkOperation<T>?
    let mapper: (InMemoryLoggingNetworkStore) -> NetworkOperation<T>?

    struct Line: Identifiable {
        let id = UUID()
        let text: String

        init(text: String.SubSequence) {
            self.text = String(text)
        }
    }

    init(
        store: InMemoryLoggingNetworkStore,
        title: String,
        missing: String,
        mapper: @escaping (InMemoryLoggingNetworkStore) -> NetworkOperation<T>?,
        fetcher: (() async throws -> ())?
    ) {
        self.store = store
        self.title = title
        self.missing = missing
        self.fetcher = fetcher
        self.mapper = mapper
    }

    func load() {
        mapResult = mapper(store)
    }

    var body: some View {
        VStack {
            if let mapResult {
                (Text("Last fetched") + Text(" ") + 
                    Text(mapResult.time, formatter: DateFormatter.forDebug()))
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
                    .padding()
            }

            if let fetcher {
                Button {
                    Task {
                        do {
                            try await fetcher()
                            load()
                        } catch {
                            fetchError = String(describing: error)
                        }
                    }
                } label: {
                    Text("Fetch now")
                }.buttonStyle(.bordered)

                OptionalView(fetchError) {
                    Text($0)
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
        .task {
            load()
        }
    }

    private var asText: String {
        guard let data = mapResult?.raw else { return "" }

        return data.formattedJSON()
    }

    private var lines: [Line] {
        asText.split(separator: "\n").map(Line.init)
    }
}

struct ResponseDebugView_Previews: PreviewProvider {
    struct TestError: Error {}

    static var previews: some View {
        let network = DemoNetworking()
        let store = InMemoryLoggingNetworkStore()
        Task {
            store.reportResponse = try NetworkOperation(description: "fetchReport", value: await network.fetchReport(deviceSN: "123", variables: [.chargeEnergyToTal], queryDate: .now(), reportType: .day), raw: "Report is only fetched and cached on the graph view. Click that page to load report data\nClick that page to load report data".data(using: .utf8)!)
        }

        return ResponseDebugView<[OpenReportResponse]>(
            store: store,
            title: "Report",
            missing: "Data is only fetched and cached on the graph view.\nClick that page to load report data",
            mapper: { $0.reportResponse },
            fetcher: { throw TestError() }
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
