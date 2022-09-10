//
//  MockNetworking.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

class MockNetworking: Network {
    private let throwOnCall: Bool

    init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
        super.init(credentials: Credentials())
    }

    override func fetchReport() async throws -> ReportResponse {
        if throwOnCall {
            throw NetworkError.unknown
        }

        return ReportResponse(result: [.init(variable: "feedin", data: [.init(index: 14, value: 1.5)])])
    }

    override func fetchBattery() async throws -> BatteryResponse {
        BatteryResponse(errno: 0, result: .init(soc: 56, power: 0.27))
    }

    override func fetchRaw(variables: [String]) async throws -> RawResponse {
        if throwOnCall {
            throw NetworkError.unknown
        }
        return RawResponse(errno: 0, result: variables.map(makeData))
    }

    private func makeData(_ title: String) -> RawResponse.ReportVariable {
        let range = ClosedRange(uncheckedBounds: (1, 30))

        return RawResponse.ReportVariable(variable: title, data: range.map { index -> RawResponse.ReportData in
            RawResponse.ReportData(time: Date().addingTimeInterval(Double(0 - index * 60)), value: Double.random(in: 0...2))
        })
    }
}
