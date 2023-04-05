//
//  RawResponseDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import SwiftUI
import Energy_Stats_Core

struct RawResponseDebugView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkingDecorator

    var body: some View {
        ScrollView {
            ForEach(network.rawResponse, id: \.self) { response in
                VStack(alignment: .leading) {
                    Text(response.variable)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(response.data, id: \.self) {
                            Text($0.time, format: .dateTime)
                            Text($0.value, format: .number)
                        }
                    }
                }
            }.padding()
        }
        .navigationTitle("Raw")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
    }

    private var asText: String {
        network.rawResponse.flatMap { response in
            [response.variable] +
            response.data.map {
                return """
                       Time: \($0.time) Value: \($0.value)
                       """
            }
        }.joined(separator: "\n")
    }
}
