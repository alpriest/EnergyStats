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
    private let shouldInvertCT2: Bool

    public init(response: OpenHistoryResponse, includeCT2: Bool, shouldInvertCT2: Bool) {
        self.response = response
        self.includeCT2 = includeCT2
        self.shouldInvertCT2 = shouldInvertCT2
    }

    public func todayGeneration() -> Double {
        var pvPowerVariables = response.datas.filter { $0.variable == "pvPower" }.flatMap { $0.data }.map { $0.copy(value: max(0, $0.value)) }
        let ct2Variables: [OpenHistoryResponse.Data.UnitData]
        if includeCT2 {
            ct2Variables = response.datas.filter { $0.variable == "meterPower2" }
                .flatMap { $0.data }
                .map {
                    if shouldInvertCT2 {
                        $0.copy(value: min(0, $0.value))
                    } else {
                        $0.copy(value: max(0, $0.value))
                    }
                }
        } else {
            ct2Variables = []
        }

        let filteredVariables = pvPowerVariables + ct2Variables

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
