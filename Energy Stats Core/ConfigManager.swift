//
//  ConfigManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2023.
//

import Combine
import Foundation

public enum RefreshFrequency: Int {
    case AUTO = 0
    case ONE_MINUTE = 1
    case FIVE_MINUTES = 5
}

public protocol ConfigManaging {
    func findDevices() async throws
    func fetchFirmwareVersions() async throws
    func logout()
    var minSOC: Double { get }
    var batteryCapacity: String { get set }
    var batteryCapacityW: Int { get }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var showUsableBatteryOnly: Bool { get set }
    var refreshFrequency: RefreshFrequency { get set }
    var appTheme: LatestAppTheme { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var currentDevice: Device? { get }
    var selectedDeviceID: String? { get set }
    var firmwareVersions: DeviceFirmwareVersion? { get }
    var showInW: Bool { get set }
}

public class ConfigManager: ConfigManaging {
    private let networking: Networking
    private var config: Config
    public var appTheme: CurrentValueSubject<AppTheme, Never>

    struct NoDeviceFoundError: Error {}

    public init(networking: Networking, config: Config) {
        self.networking = networking
        self.config = config
        appTheme = CurrentValueSubject(
            AppTheme(
                showColouredLines: config.showColouredLines,
                showBatteryTemperature: config.showBatteryTemperature,
                showSunnyBackground: config.showSunnyBackground,
                decimalPlaces: config.decimalPlaces,
                showBatteryEstimate: config.showBatteryEstimate,
                showUsableBatteryOnly: config.showUsableBatteryOnly,
                showInW: config.showInW
            )
        )
    }

    public func findDevices() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard deviceList.devices.count > 0 else {
            throw NoDeviceFoundError()
        }

        devices = try await deviceList.devices.asyncMap { device in
            let batteryCapacity: String?
            let minSOC: String?

            if device.hasBattery {
                let battery = try await networking.fetchBattery(deviceID: device.deviceID)
                let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)
                batteryCapacity = String(Int(battery.residual / (Double(battery.soc) / 100.0)))
                minSOC = String(Double(batterySettings.minSoc) / 100.0)
            } else {
                batteryCapacity = nil
                minSOC = nil
            }

            return Device(
                plantName: device.plantName,
                deviceID: device.deviceID,
                deviceSN: device.deviceSN,
                hasPV: device.hasPV,
                battery: device.hasBattery ? Device.Battery(capacity: batteryCapacity, minSOC: minSOC) : nil
            )
        }
        selectedDeviceID = devices?.first?.deviceID
    }

    public func fetchFirmwareVersions() async throws {
        guard let deviceID = config.selectedDeviceID else { throw NoDeviceFoundError() }

        let response = try await networking.fetchAddressBook(deviceID: deviceID)
        firmwareVersions = DeviceFirmwareVersion(
            master: response.softVersion.master,
            slave: response.softVersion.slave,
            manager: response.softVersion.manager
        )
    }

    public func logout() {
        config.selectedDeviceID = nil
        config.devices = nil
        config.isDemoUser = false
    }

    public private(set) var firmwareVersions: DeviceFirmwareVersion? = nil

    public var minSOC: Double { Double(currentDevice?.battery?.minSOC ?? "0.2") ?? 0.0 }

    public var batteryCapacity: String {
        get { currentDevice?.battery?.capacity ?? "2600" }
        set {
            devices = devices?.map {
                if $0.deviceID == currentDevice?.deviceID, let battery = $0.battery {
                    return Device(plantName: $0.plantName, deviceID: $0.deviceID, deviceSN: $0.deviceSN, hasPV: $0.hasPV, battery: Device.Battery(capacity: newValue, minSOC: battery.minSOC))
                } else {
                    return $0
                }
            }
        }
    }

    public var batteryCapacityW: Int {
        Int(currentDevice?.battery?.capacity ?? "0") ?? 0
    }

    public var currentDevice: Device? {
        devices?.first(where: { $0.deviceID == selectedDeviceID }) ?? devices?.first
    }

    public var selectedDeviceID: String? {
        get { config.selectedDeviceID }
        set { config.selectedDeviceID = newValue }
    }

    public var isDemoUser: Bool {
        get { config.isDemoUser }
        set {
            config.isDemoUser = newValue
        }
    }

    public var showColouredLines: Bool {
        get { config.showColouredLines }
        set {
            config.showColouredLines = newValue
            appTheme.send(appTheme.value.update(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    public var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appTheme.send(appTheme.value.update(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    public var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appTheme.send(appTheme.value.update(
                showBatteryEstimate: config.showBatteryEstimate
            ))
        }
    }

    public var showUsableBatteryOnly: Bool {
        get { config.showUsableBatteryOnly }
        set {
            config.showUsableBatteryOnly = newValue
            appTheme.send(appTheme.value.update(
                showUsableBatteryOnly: config.showUsableBatteryOnly
            ))
        }
    }

    public var refreshFrequency: RefreshFrequency {
        get { RefreshFrequency(rawValue: config.refreshFrequency) ?? .AUTO }
        set { config.refreshFrequency = newValue.rawValue }
    }

    public var showSunnyBackground: Bool {
        get { config.showSunnyBackground }
        set {
            config.showSunnyBackground = newValue
            appTheme.send(appTheme.value.update(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    public var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appTheme.send(appTheme.value.update(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    public var showInW: Bool {
        get { config.showInW }
        set {
            config.showInW = newValue
            appTheme.send(appTheme.value.update(
                showInW: config.showInW
            ))
        }
    }

    public var devices: [Device]? {
        get {
            guard let deviceListData = config.devices else { return nil }
            do {
                return try JSONDecoder().decode([Device].self, from: deviceListData)
            } catch {
                return nil
            }
        }
        set {
            if let newValue {
                do {
                    config.devices = try JSONEncoder().encode(newValue)
                } catch {
                    print("AWP", "Failed to encode device list 💥")
                }
            } else {
                config.devices = nil
            }
        }
    }
}
