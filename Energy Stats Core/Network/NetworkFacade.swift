//
//  NetworkFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

public class NetworkFacade: Networking {
    private let network: Networking
    private let fakeNetwork: Networking
    private let config: Config
    private let store: KeychainStoring

    public init(network: Networking, config: Config, store: KeychainStoring) {
        self.network = network
        self.fakeNetwork = DemoNetworking()
        self.config = config
        self.store = store
    }

    private var isDemoUser: Bool {
        config.isDemoUser || store.isDemoUser
    }

    public func ensureHasToken() async {
        if isDemoUser {
            await fakeNetwork.ensureHasToken()
        } else {
            await network.ensureHasToken()
        }
    }

    public func verifyCredentials(username: String, hashedPassword: String) async throws {
        if isDemoUser {
            try await fakeNetwork.verifyCredentials(username: username, hashedPassword: hashedPassword)
        } else {
            try await network.verifyCredentials(username: username, hashedPassword: hashedPassword)
        }
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        return if isDemoUser {
            try await fakeNetwork.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
        } else {
            try await network.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
        }
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchBattery(deviceID: deviceID)
        } else {
            try await network.fetchBattery(deviceID: deviceID)
        }
    }

    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchBatterySettings(deviceSN: deviceSN)
        } else {
            try await network.fetchBatterySettings(deviceSN: deviceSN)
        }
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        return if isDemoUser {
            try await fakeNetwork.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
        } else {
            try await network.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
        }
    }

    public func fetchDeviceList() async throws -> [PagedDeviceListResponse.Device] {
        return if isDemoUser {
            try await fakeNetwork.fetchDeviceList()
        } else {
            try await network.fetchDeviceList()
        }
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchAddressBook(deviceID: deviceID)
        } else {
            try await network.fetchAddressBook(deviceID: deviceID)
        }
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        return if isDemoUser {
            try await fakeNetwork.fetchVariables(deviceID: deviceID)
        } else {
            try await network.fetchVariables(deviceID: deviceID)
        }
    }

    public func fetchEarnings(deviceID: String) async throws -> EarningsResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchEarnings(deviceID: deviceID)
        } else {
            try await network.fetchEarnings(deviceID: deviceID)
        }
    }

    public func setSoc(minGridSOC: Int, minSOC: Int, deviceSN: String) async throws {
        return if isDemoUser {
            try await fakeNetwork.setSoc(minGridSOC: minGridSOC, minSOC: minSOC, deviceSN: deviceSN)
        } else {
            try await network.setSoc(minGridSOC: minGridSOC, minSOC: minSOC, deviceSN: deviceSN)
        }
    }

    public func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchBatteryTimes(deviceSN: deviceSN)
        } else {
            try await network.fetchBatteryTimes(deviceSN: deviceSN)
        }
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        return if isDemoUser {
            try await fakeNetwork.setBatteryTimes(deviceSN: deviceSN, times: times)
        } else {
            try await network.setBatteryTimes(deviceSN: deviceSN, times: times)
        }
    }

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchWorkMode(deviceID: deviceID)
        } else {
            try await network.fetchWorkMode(deviceID: deviceID)
        }
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {
        return if isDemoUser {
            try await fakeNetwork.setWorkMode(deviceID: deviceID, workMode: workMode)
        } else {
            try await network.setWorkMode(deviceID: deviceID, workMode: workMode)
        }
    }

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchDataLoggers()
        } else {
            try await network.fetchDataLoggers()
        }
    }

    public func fetchErrorMessages() async {
        if isDemoUser {
            await fakeNetwork.fetchErrorMessages()
        } else {
            await network.fetchErrorMessages()
        }
    }
}
