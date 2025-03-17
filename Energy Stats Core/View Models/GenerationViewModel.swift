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
            let ct2Variables = response.datas.filter { $0.variable == "meterPower2" }
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

            let timeDifferenceInSeconds: TimeInterval
            if let firstTime = ct2Variables[safe: 0]?.time, let secondTime = ct2Variables[safe: 1]?.time {
                timeDifferenceInSeconds = (secondTime.timeIntervalSince1970 - firstTime.timeIntervalSince1970)
            } else {
                timeDifferenceInSeconds = 5.0 * 60.0
            }

            ct2Total = Double(ct2Variables.reduce(0) { $0 + $1.value })
                * (timeDifferenceInSeconds / 3600.0)
        } else {
            ct2Total = 0
        }

        return pvTotal + ct2Total
    }
}
