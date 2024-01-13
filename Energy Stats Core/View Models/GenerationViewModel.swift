//
//  GenerationViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/01/2024.
//

import Foundation

public struct GenerationViewModel {
    private let response: [OpenReportResponse]

    public init(response: [OpenReportResponse]) {
        self.response = response
    }

    public func todayGeneration(_ model: TotalSolarYieldModel) -> Double { // TODO: Remove parameter
        return 0 // TODO: Get below working when we see the data
//        let filteredVariables = response.filter { $0.variable == "pvPower" }.flatMap { $0.values }
//
//        let timeDifferenceInSeconds: TimeInterval
//        if let firstTime = filteredVariables[safe: 0]?.time, let secondTime = filteredVariables[safe: 1]?.time {
//            timeDifferenceInSeconds = (secondTime.timeIntervalSince1970 - firstTime.timeIntervalSince1970)
//        } else {
//            timeDifferenceInSeconds = 5.0 * 60.0
//        }
//
//        let totalSum = filteredVariables.reduce(0) { $0 + $1.value }
//
//        return Double(totalSum) * (timeDifferenceInSeconds / 3600.0)
    }
}
