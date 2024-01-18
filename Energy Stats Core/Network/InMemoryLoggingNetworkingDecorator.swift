//
//  InMemoryLoggingNetworkingDecorator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/04/2023.
//

import Foundation

public class InMemoryLoggingNetworkStore: ObservableObject {
    public var reportResponse: NetworkOperation<[OpenReportResponse]>?
    public var batterySettingsResponse: NetworkOperation<BatterySOCResponse>?
    public var queryResponse: NetworkOperation<OpenQueryResponse>?
    public var deviceListResponse: NetworkOperation<[DeviceDetailResponse]>?
    public var variables: NetworkOperation<OpenApiVariableArray>?
    public var batteryTimesResponse: NetworkOperation<BatteryTimesResponse>?

    public static let shared = InMemoryLoggingNetworkStore()

    public init() {}

    public func logout() {
        reportResponse = nil
        batterySettingsResponse = nil
        queryResponse = nil
        deviceListResponse = nil
        variables = nil
        batteryTimesResponse = nil
    }

    public var latestRequest: URLRequest?
    public var latestData: Data?
    public var latestResponse: URLResponse?
}

public struct NetworkOperation<T: Decodable> {
    public let time: Date = .init()
    public let description: String
    public let value: T
    public let raw: Data

    public init(description: String, value: T, raw: Data) {
        self.description = description
        self.value = value
        self.raw = raw
    }
}
