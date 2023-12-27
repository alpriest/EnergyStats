//
//  NetworkValueCleaner.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/10/2023.
//

import Foundation

public class NetworkValueCleaner: FoxESSNetworking {
    private let network: FoxESSNetworking
    private let appSettingsPublisher: LatestAppSettingsPublisher

    public init(network: FoxESSNetworking, appSettingsPublisher: LatestAppSettingsPublisher) {
        self.network = network
        self.appSettingsPublisher = appSettingsPublisher
    }

    public func fetchErrorMessages() async {
        await network.fetchErrorMessages()
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let original = try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)

        return OpenQueryResponse(time: original.time, deviceSN: deviceSN, datas: original.datas.map { originalData in
            OpenQueryResponse.Data(unit: originalData.unit,
                                   variable: originalData.variable,
                                   value: originalData.value.capped(appSettingsPublisher.value.dataCeiling))
        })
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse {
        let original = try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables)

        return OpenHistoryResponse(deviceSN: original.deviceSN, datas: original.datas.map { originalData in
            OpenHistoryResponse.Data(unit: originalData.unit,
                                     name: originalData.name,
                                     variable: originalData.variable,
                                     data: originalData.data.map {
                                         OpenHistoryResponse.Data.UnitData(time: $0.time, value: $0.value.capped(appSettingsPublisher.value.dataCeiling))
                                     })
        })
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await network.openapi_fetchVariables()
    }

    public func openapi_fetchDeviceList() async throws -> [String] {
        try await network.openapi_fetchDeviceList()
    }
}

extension Double {
    func capped(_ ceiling: DataCeiling) -> Double {
        guard self > 0 else { return self }

        let register = Int(self * 10)
        let mask = switch ceiling {
        case .none:
            0x0
        case .mild:
            0xfff00000
        case .enhanced:
            0xffff0000
        }

        let masked = register & mask
        if masked == 0 {
            return self
        } else {
            return self - (Double(masked) / 10.0).rounded(decimalPlaces: 3)
        }
    }
}
