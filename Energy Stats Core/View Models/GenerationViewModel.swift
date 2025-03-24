//
//  GenerationViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/01/2024.
//

import Foundation

public struct GenerationViewModel {
    private let pvTotal: Double
    private let response: OpenHistoryResponse
    private let includeCT2: Bool
    private let shouldInvertCT2: Bool

    public init(pvTotal: Double, response: OpenHistoryResponse, includeCT2: Bool, shouldInvertCT2: Bool) {
        self.pvTotal = pvTotal
        self.response = response
        self.includeCT2 = includeCT2
        self.shouldInvertCT2 = shouldInvertCT2
    }

    public func todayGeneration() -> Double {
        let ct2Total: Double

        if includeCT2 {
            ct2Total = response.datas.filter { $0.variable == "meterPower2" }
                .flatMap { $0.data }
                .compactMap {
                    if shouldInvertCT2 {
                        if $0.value < 0 {
                            $0.copy(value: abs($0.value))
                        } else {
                            nil
                        }
                    } else {
                        if $0.value > 0 {
                            $0.copy(value: $0.value)
                        } else {
                            nil
                        }
                    }
                }
                .sorted { $0.time < $1.time }
                .adjacentPairs()
                .map { (a, b) -> Double in
                    let dt = b.time.timeIntervalSince(a.time)
                    let averageValue = (a.value + b.value) / 2.0
                    return averageValue * dt / 3600.0
                }
                .reduce(0, +)
        } else {
            ct2Total = 0
        }

        return pvTotal + ct2Total
    }
}

private extension Array {
    func adjacentPairs() -> [(Element, Element)] {
        guard count >= 2 else { return [] }
        return (0..<(count - 1)).map { (self[$0], self[$0 + 1]) }
    }
}
