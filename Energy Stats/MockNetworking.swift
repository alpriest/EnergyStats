//
//  MockNetworking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

class MockNetworking: Network {
    private let throwOnCall: Bool

    init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
        super.init(credentials: KeychainStore(), config: MockConfig())
    }

    override func fetchReport(variables: [VariableType]) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        return [ReportResponse(variable: "feedin", data: [.init(index: 14, value: 1.5)])]
    }

    override func fetchBattery() async throws -> BatteryResponse {
        BatteryResponse(soc: 56, power: 0.27)
    }

    override func fetchRaw(variables: [VariableType]) async throws -> [RawResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        let response = try JSONDecoder().decode(NetworkResponse<[RawResponse]>.self, from: rawData())
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.map {
            RawResponse(variable: $0.variable, data: $0.data.map {
                let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)

                let date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: Date())

                return RawResponse.ReportData(time: date ?? $0.time, value: $0.value)
            })
        }
    }

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}

class MockConfig: Config {
    var minSOC: String?
    var batteryCapacity: String?
    var deviceID: String?
    var hasBattery: Bool = true
    var hasPV: Bool = true
    var isDemoUser: Bool = false
}
