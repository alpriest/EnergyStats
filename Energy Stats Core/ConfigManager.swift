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

public extension Notification.Name {
    static let deviceChanged = Notification.Name(rawValue: "DeviceChanged")
}

public protocol ConfigManaging {
    func fetchDevices() async throws
    func logout()
    func select(device: Device?)
    func refreshFirmwareVersions() async throws
    var minSOC: Double { get }
    var batteryCapacity: String { get set }
    var batteryCapacityW: Int { get }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var showUsableBatteryOnly: Bool { get set }
    var showTotalYield: Bool { get set }
    var refreshFrequency: RefreshFrequency { get set }
    var appTheme: LatestAppTheme { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var selectedDeviceID: String? { get }
    var firmwareVersions: DeviceFirmwareVersion? { get }
    var showInW: Bool { get set }
    var variables: [RawVariable] { get }
    var currentDevice: CurrentValueSubject<Device?, Never> { get }
    var hasBattery: Bool { get }
    var showEarnings: Bool { get set }
    var showInverterTemperature: Bool { get set }
}

public class ConfigManager: ConfigManaging {
    private let networking: Networking
    private var config: Config
    public var appTheme: CurrentValueSubject<AppTheme, Never>
    public var currentDevice = CurrentValueSubject<Device?, Never>(nil)

    public struct NoDeviceFoundError: Error {
        public init() {}
    }

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
                showInW: config.showInW,
                showTotalYield: config.showTotalYield,
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode,
                showEarnings: config.showEarnings,
                showInverterTemperature: config.showInverterTemperature
            )
        )
        selectedDeviceID = selectedDeviceID
    }

    public func fetchDevices() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard deviceList.devices.count > 0 else {
            throw NoDeviceFoundError()
        }

        let newDevices = try await deviceList.devices.asyncMap { device in
            let deviceBattery: Device.Battery?
            let firmware = try await fetchFirmwareVersions(deviceID: device.deviceID)
            let variables = try await networking.fetchVariables(deviceID: device.deviceID)

            if device.hasBattery {
                do {
                    let battery = try await networking.fetchBattery(deviceID: device.deviceID)
                    let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)

                    deviceBattery = BatteryResponseMapper.map(battery: battery, settings: batterySettings)
                } catch {
                    deviceBattery = nil
                }
            } else {
                deviceBattery = nil
            }

            return Device(
                plantName: device.plantName,
                deviceID: device.deviceID,
                deviceSN: device.deviceSN,
                hasPV: device.hasPV,
                battery: deviceBattery,
                deviceType: device.deviceType,
                firmware: firmware,
                variables: variables,
                moduleSN: device.moduleSN
            )
        }
        devices = newDevices
        select(device: devices?.first)
    }

    private func fetchFirmwareVersions(deviceID: String) async throws -> DeviceFirmwareVersion {
        let firmware = try await networking.fetchAddressBook(deviceID: deviceID)

        return DeviceFirmwareVersion(
            master: firmware.softVersion.master,
            slave: firmware.softVersion.slave,
            manager: firmware.softVersion.manager
        )
    }

    public func refreshFirmwareVersions() async throws {
        devices = try await devices?.asyncMap { [weak self] in
            let firmware = try await self?.fetchFirmwareVersions(deviceID: $0.deviceID)
            if firmware != $0.firmware {
                return $0.copy(firmware: firmware)
            } else {
                return $0
            }
        }
    }

    public func logout() {
        config.selectedDeviceID = nil
        config.devices = nil
        config.isDemoUser = false
    }

    public func select(device: Device?) {
        guard let device else { return }

        selectedDeviceID = device.deviceID
    }

    public var firmwareVersions: DeviceFirmwareVersion? {
        currentDevice.value?.firmware
    }

    public var minSOC: Double { Double(currentDevice.value?.battery?.minSOC ?? "0.2") ?? 0.0 }

    public var variables: [RawVariable] {
        currentDevice.value?.variables ?? []
    }

    public var batteryCapacity: String {
        get { currentDevice.value?.battery?.capacity ?? "2600" }
        set {
            devices = devices?.map {
                if $0.deviceID == currentDevice.value?.deviceID, let battery = $0.battery {
                    return $0.copy(battery: Device.Battery(capacity: newValue, minSOC: battery.minSOC))
                } else {
                    return $0
                }
            }
        }
    }

    public var hasBattery: Bool {
        currentDevice.value?.battery != nil
    }

    public var batteryCapacityW: Int {
        Int(currentDevice.value?.battery?.capacity ?? "0") ?? 0
    }

    public var selectedDeviceID: String? {
        get { config.selectedDeviceID }
        set {
            config.selectedDeviceID = newValue
            currentDevice.send(devices?.first(where: { $0.deviceID == selectedDeviceID }) ?? devices?.first)
        }
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

    public var showTotalYield: Bool {
        get { config.showTotalYield }
        set {
            config.showTotalYield = newValue
            appTheme.send(appTheme.value.update(
                showTotalYield: config.showTotalYield
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

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get { config.selfSufficiencyEstimateMode }
        set {
            config.selfSufficiencyEstimateMode = newValue
            appTheme.send(appTheme.value.update(
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode
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

    public var showEarnings: Bool {
        get { config.showEarnings }
        set {
            config.showEarnings = newValue
            appTheme.send(appTheme.value.update(
                showEarnings: config.showEarnings
            ))
        }
    }

    public var showInverterTemperature: Bool {
        get { config.showInverterTemperature }
        set {
            config.showInverterTemperature = newValue
            appTheme.send(appTheme.value.update(
                showInverterTemperature: config.showInverterTemperature
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

public enum BatteryResponseMapper {
    public static func map(battery: BatteryResponse, settings: BatterySettingsResponse) -> Device.Battery {
        let batteryCapacity: String
        let minSOC: String

        if battery.soc > 0 {
            batteryCapacity = String(Int(Double(battery.residual) / (Double(battery.soc) / 100.0)))
        } else {
            batteryCapacity = "0"
        }
        minSOC = String(Double(settings.minGridSoc) / 100.0)

        return Device.Battery(capacity: batteryCapacity, minSOC: minSOC)
    }
}
