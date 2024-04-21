//
//  InMemoryLoggingNetworkingDecorator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/04/2023.
//

import Foundation

public class InMemoryLoggingNetworkStore: ObservableObject {
    @MainActor
    public var reportResponse: NetworkOperation<[OpenReportResponse]>?
    @MainActor
    public var batterySettingsResponse: NetworkOperation<BatterySOCResponse>?
    @MainActor
    public var queryResponse: NetworkOperation<OpenQueryResponse>?
    @MainActor
    public var deviceListResponse: NetworkOperation<[DeviceSummaryResponse]>?
    @MainActor
    public var variables: NetworkOperation<OpenApiVariableArray>?
    @MainActor
    public var batteryTimesResponse: NetworkOperation<BatteryTimesResponse>?

    public static let shared = InMemoryLoggingNetworkStore()

    public init() {}

    @MainActor
    public func logout() {
        reportResponse = nil
        batterySettingsResponse = nil
        queryResponse = nil
        deviceListResponse = nil
        variables = nil
        batteryTimesResponse = nil
    }

    @MainActor
    public var latestRequest: URLRequest?
    @MainActor
    public var latestData: Data?
    @MainActor
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
