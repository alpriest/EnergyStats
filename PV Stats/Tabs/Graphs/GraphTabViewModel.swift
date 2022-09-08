//
//  GraphTabViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

class GraphTabViewModel: ObservableObject {
    private var networking: Networking
    @Published var data: [GraphValue] = []

    init(_ networking: Networking) {
        self.networking = networking
    }

    func start() {
        Task {
            let raw = try await networking.fetchRaw()

            let data: [GraphValue] = raw.result.flatMap { reportVariable in
                reportVariable.data.compactMap {
                    return GraphValue(date: $0.time, value: $0.value, variable: reportVariable.variable)
                }
            }

            await MainActor.run { self.data = data }
        }
    }
}

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: String

    var id: Date { date }
}
