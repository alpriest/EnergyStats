//
//  GenerationViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/01/2024.
//

import Foundation

public struct GenerationViewModel {
    private let raws: [RawResponse]
    private let todayGeneration: Double

    public init(raws: [RawResponse], todayGeneration: Double) {
        self.raws = raws
        self.todayGeneration = todayGeneration
    }

    public func todayGeneration(_ model: TotalSolarYieldModel) -> Double {
        switch model {
        case .off:
            0
        case .energyStats:
            calculateSolar(raws)
        case .foxESS:
            todayGeneration
        }
    }

    func calculateSolar(_ raws: [RawResponse]) -> Double {
        let filteredVariables = raws.filter { $0.variable == "pvPower" }

        let totalSum = filteredVariables.flatMap { $0.data }.reduce(0) { $0 + $1.value }

        return Double(totalSum) / 12.0
    }
}
