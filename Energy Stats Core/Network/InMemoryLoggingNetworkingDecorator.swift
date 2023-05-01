//
//  InMemoryLoggingNetworkingDecorator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/04/2023.
//

import Foundation

public class InMemoryLoggingNetworkStore: ObservableObject {
    public var reportResponse: NetworkOperation<[ReportResponse]>?
    public var batteryResponse: NetworkOperation<BatteryResponse>?
    public var batterySettingsResponse: NetworkOperation<BatterySettingsResponse>?
    public var rawResponse: NetworkOperation<[RawResponse]>?
    public var deviceListResponse: NetworkOperation<PagedDeviceListResponse>?
    public var addressBookResponse: NetworkOperation<AddressBookResponse>?
    public var variables: NetworkOperation<VariablesResponse>?

    public init() {}
}

public struct NetworkOperation<T: Decodable> {
    public let time: Date = Date()
    public let description: String
    public let value: T
    public let raw: Data

    public init(description: String, value: T, raw: Data) {
        self.description = description
        self.value = value
        self.raw = raw
    }
}
