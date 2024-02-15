//
//  GenerationViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/01/2024.
//

import Foundation

public struct GenerationViewModel {
    private let response: OpenHistoryResponse
    private let includeCT2: Bool

    public init(response: OpenHistoryResponse, includeCT2: Bool) {
        self.response = response
        self.includeCT2 = includeCT2
    }

    public func todayGeneration() -> Double {
        let filteredVariables = response.datas.filter { $0.variable == "pvPower" || ($0.variable == "meterPower2" && includeCT2) }.flatMap { $0.data }

        let timeDifferenceInSeconds: TimeInterval
        if let firstTime = filteredVariables[safe: 0]?.time, let secondTime = filteredVariables[safe: 1]?.time {
            timeDifferenceInSeconds = (secondTime.timeIntervalSince1970 - firstTime.timeIntervalSince1970)
        } else {
            timeDifferenceInSeconds = 5.0 * 60.0
        }

        let totalSum = filteredVariables.reduce(0) { $0 + $1.value }

        return Double(totalSum) * (timeDifferenceInSeconds / 3600.0)
    }
}
