//
//  GraphTabViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation
import SwiftUI

class GraphTabViewModel: ObservableObject {
    private var networking: Networking
    private var rawData: [GraphValue] = [] {
        didSet {
            data = rawData
        }
    }

    @Published var data: [GraphValue] = []
    private(set) var variables = ["feedinPower", "generationPower", "gridConsumptionPower", "batChargePower", "pvPower"]
    private var hiddenVariables: Set<String> = .init()

    init(_ networking: Networking) {
        self.networking = networking
    }

    func start() {
        Task {
            let raw = try await networking.fetchRaw(variables: variables)

            let data: [GraphValue] = raw.result.flatMap { reportVariable in
                reportVariable.data.compactMap {
                    GraphValue(date: $0.time, value: $0.value, variable: reportVariable.variable)
                }
            }

            await MainActor.run { self.rawData = data }
        }
    }

    func toggle(_ series: String) {
        if hiddenVariables.contains(series) {
            hiddenVariables.remove(series)
        } else {
            hiddenVariables.insert(series)
        }

        data = rawData.filter { !hiddenVariables.contains($0.variable) }
    }

    func isEnabled(_ series: String) -> Bool {
        !hiddenVariables.contains(series)
    }

    func color(for series: String) -> Color {
        let hash = abs(series.hash)
        let colorNum = hash % (256 * 256 * 256)
        let red = colorNum >> 16
        let green = (colorNum & 0x00FF00) >> 8
        let blue = (colorNum & 0x0000FF)

        return Color(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0)
    }

    var series: [String] {
        Array(Dictionary(grouping: data, by: { $0.variable }).keys.sorted(by: { $0 < $1 }))
    }
}

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: String

    var id: Date { date }
}
