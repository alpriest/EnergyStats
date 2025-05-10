//
//  GenerationViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/01/2024.
//

import Foundation

public enum StringType {
    case pv1
    case pv2
    case pv3
    case pv4
    case pv5
    case pv6
    case ct2
}

public struct GenerationViewModel {
    private let pvTotal: Double
    private let includeCT2: Bool
    private let shouldInvertCT2: Bool
    public let pv1Total: Double
    public let pv2Total: Double
    public let pv3Total: Double
    public let pv4Total: Double
    public let pv5Total: Double
    public let pv6Total: Double
    private let ct2Total: Double

    public init(pvTotal: Double, response: OpenHistoryResponse, includeCT2: Bool, shouldInvertCT2: Bool) {
        self.pvTotal = pvTotal
        self.includeCT2 = includeCT2
        self.shouldInvertCT2 = shouldInvertCT2
        pv1Total = response.trapezoidalAverage(key: "pv1Power")
        pv2Total = response.trapezoidalAverage(key: "pv2Power")
        pv3Total = response.trapezoidalAverage(key: "pv3Power")
        pv4Total = response.trapezoidalAverage(key: "pv4Power")
        pv5Total = response.trapezoidalAverage(key: "pv5Power")
        pv6Total = response.trapezoidalAverage(key: "pv6Power")
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
            .map { a, b -> Double in
                let dt = b.time.timeIntervalSince(a.time)
                let averageValue = (a.value + b.value) / 2.0
                return averageValue * dt / 3600.0
            }
            .reduce(0, +)
    }

    public var todayGeneration: Double {
        pvTotal + (includeCT2 ? ct2Total : 0)
    }

    public func estimatedTotal(string: StringType) -> Double {
        switch string {
        case .pv1:
            pv1Total
        case .pv2:
            pv2Total
        case .pv3:
            pv3Total
        case .pv4:
            pv4Total
        case .pv5:
            pv5Total
        case .pv6:
            pv6Total
        case .ct2:
            ct2Total
        }
    }
}

private extension Array {
    func adjacentPairs() -> [(Element, Element)] {
        guard count >= 2 else { return [] }
        return (0 ..< (count - 1)).map { (self[$0], self[$0 + 1]) }
    }
}

private extension OpenHistoryResponse {
    func trapezoidalAverage(key: String) -> Double {
        datas.filter { $0.variable == key }
            .flatMap { $0.data }
            .sorted { $0.time < $1.time }
            .adjacentPairs()
            .map { a, b -> Double in
                let dt = b.time.timeIntervalSince(a.time)
                let averageValue = (a.value + b.value) / 2.0
                return averageValue * dt / 3600.0
            }
            .reduce(0, +)
    }
}
