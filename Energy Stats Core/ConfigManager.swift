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

public protocol ConfigManaging: FinancialConfigManaging, SolcastConfigManaging {
    func fetchDevices() async throws
    func logout()
    func select(device: Device?)
    func refreshFirmwareVersions() async throws
    func clearBatteryOverride(for deviceID: String)
    var hasRunBefore: Bool { get set }
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
    var appSettings: LatestAppPublisher { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var selectedDeviceID: String? { get }
    var firmwareVersions: DeviceFirmwareVersion? { get }
    var displayUnit: DisplayUnit { get set }
    var variables: [RawVariable] { get }
    var currentDevice: CurrentValueSubject<Device?, Never> { get }
    var hasBattery: Bool { get }
    var showInverterTemperature: Bool { get set }
    var selectedParameterGraphVariables: [String] { get set }
    var showHomeTotalOnPowerFlow: Bool { get set }
    var showInverterIcon: Bool { get set }
    var shouldInvertCT2: Bool { get set }
    var showInverterPlantName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showInverterTypeNameOnPowerFlow: Bool { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
    var currencySymbol: String { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var showGraphValueDescriptions: Bool { get set }
}

public protocol SolcastConfigManaging {
    var solcastSettings: SolcastSettings { get set }
}

public protocol FinancialConfigManaging {
    var showFinancialEarnings: Bool { get set }
    var financialModel: FinancialModel { get set }
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
}

public class ConfigManager: ConfigManaging {
    private let networking: FoxESSNetworking
    private var config: Config
    public var appSettings: CurrentValueSubject<AppSettings, Never>
    public var currentDevice = CurrentValueSubject<Device?, Never>(nil)

    public struct NoDeviceFoundError: Error {
        public init() {}
    }

    public struct NoBattery: Error {
        public init() {}
    }

    public init(networking: FoxESSNetworking, config: Config) {
        self.networking = networking
        self.config = config
        appSettings = CurrentValueSubject(
            AppSettings(
                showColouredLines: config.showColouredLines,
                showBatteryTemperature: config.showBatteryTemperature,
                showSunnyBackground: config.showSunnyBackground,
                decimalPlaces: config.decimalPlaces,
                showBatteryEstimate: config.showBatteryEstimate,
                showUsableBatteryOnly: config.showUsableBatteryOnly,
                displayUnit: DisplayUnit(rawValue: config.displayUnit) ?? .kilowatt,
                showTotalYield: config.showTotalYield,
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode,
                showFinancialEarnings: config.showFinancialEarnings,
                financialModel: FinancialModel(rawValue: config.financialModel) ?? .foxESS,
                feedInUnitPrice: config.feedInUnitPrice,
                gridImportUnitPrice: config.gridImportUnitPrice,
                showInverterTemperature: config.showInverterTemperature,
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow,
                showInverterIcon: config.showInverterIcon,
                shouldInvertCT2: config.shouldInvertCT2,
                showInverterPlantName: config.showInverterPlantName,
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow,
                showInverterTypeNameOnPowerFlow: config.showInverterTypeNameOnPowerFlow,
                showLastUpdateTimestamp: config.showLastUpdateTimestamp,
                solarDefinitions: config.solarDefinitions,
                parameterGroups: config.parameterGroups,
                shouldCombineCT2WithPVPower: config.shouldCombineCT2WithPVPower,
                showGraphValueDescriptions: config.showGraphValueDescriptions,
                solcastSettings: config.solcastSettings
            )
        )
        selectedDeviceID = selectedDeviceID

        migrateSolcast()
    }

    private func migrateSolcast() {
        if let resourceId = UserDefaults.shared.string(forKey: "solcastResourceId"),
           let apiKey = UserDefaults.shared.string(forKey: "solcastApiKey")
        {
            UserDefaults.shared.removeObject(forKey: "solcastResourceId")
            UserDefaults.shared.removeObject(forKey: "solcastApiKey")

            solcastSettings = SolcastSettings(sites: [SolcastSettings.Site(resourceId: resourceId, apiKey: apiKey, name: nil)].compactMap { $0 })
        }
    }

    public func fetchDevices() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard deviceList.count > 0 else {
            throw NoDeviceFoundError()
        }

        let newDevices = try await deviceList.asyncMap { device in
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
                hasBattery: device.hasBattery,
                battery: deviceBattery,
                deviceType: device.deviceType,
                firmware: firmware,
                variables: variables,
                moduleSN: device.moduleSN
            )
        }
        devices = newDevices
        if selectedDeviceID == nil {
            select(device: devices?.first)
        }
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
        config.clear()
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
        get {
            if let currentDevice = currentDevice.value {
                let override = config.deviceBatteryOverrides[currentDevice.deviceID]

                return override ?? currentDevice.battery?.capacity ?? "0"
            } else {
                return "0"
            }
        }
        set {
            if let currentDevice = currentDevice.value {
                config.deviceBatteryOverrides[currentDevice.deviceID] = newValue
            }

            devices = devices?.map {
                $0
            }
        }
    }

    public var hasRunBefore: Bool {
        get { config.hasRunBefore }
        set { config.hasRunBefore = newValue }
    }

    public func clearBatteryOverride(for deviceID: String) {
        config.deviceBatteryOverrides.removeValue(forKey: deviceID)
    }

    public var hasBattery: Bool {
        currentDevice.value?.hasBattery ?? false
    }

    public var batteryCapacityW: Int {
        Int(batteryCapacity) ?? 0
    }

    public var selectedDeviceID: String? {
        get { config.selectedDeviceID }
        set {
            config.selectedDeviceID = newValue
            currentDevice.send(devices?.first(where: { $0.deviceID == selectedDeviceID }) ?? devices?.first)
        }
    }

    public var currencySymbol: String {
        get { config.currencySymbol }
        set {
            config.currencySymbol = newValue
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
            appSettings.send(appSettings.value.copy(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    public var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appSettings.send(appSettings.value.copy(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    public var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appSettings.send(appSettings.value.copy(
                showBatteryEstimate: config.showBatteryEstimate
            ))
        }
    }

    public var showUsableBatteryOnly: Bool {
        get { config.showUsableBatteryOnly }
        set {
            config.showUsableBatteryOnly = newValue
            appSettings.send(appSettings.value.copy(
                showUsableBatteryOnly: config.showUsableBatteryOnly
            ))
        }
    }

    public var showTotalYield: Bool {
        get { config.showTotalYield }
        set {
            config.showTotalYield = newValue
            appSettings.send(appSettings.value.copy(
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
            appSettings.send(appSettings.value.copy(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get { config.selfSufficiencyEstimateMode }
        set {
            config.selfSufficiencyEstimateMode = newValue
            appSettings.send(appSettings.value.copy(
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode
            ))
        }
    }

    public var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appSettings.send(appSettings.value.copy(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    public var displayUnit: DisplayUnit {
        get { DisplayUnit(rawValue: config.displayUnit) ?? .kilowatt }
        set {
            config.displayUnit = newValue.rawValue
            appSettings.send(appSettings.value.copy(
                displayUnit: newValue
            ))
        }
    }

    public var showFinancialEarnings: Bool {
        get { config.showFinancialEarnings }
        set {
            config.showFinancialEarnings = newValue
            appSettings.send(appSettings.value.copy(
                showFinancialEarnings: config.showFinancialEarnings
            ))
        }
    }

    public var financialModel: FinancialModel {
        get { FinancialModel(rawValue: config.financialModel) ?? .foxESS }
        set {
            config.financialModel = newValue.rawValue
            appSettings.send(appSettings.value.copy(
                financialModel: FinancialModel(rawValue: config.financialModel)
            ))
        }
    }

    public var feedInUnitPrice: Double {
        get { config.feedInUnitPrice }
        set {
            config.feedInUnitPrice = newValue
            appSettings.send(appSettings.value.copy(
                feedInUnitPrice: config.feedInUnitPrice
            ))
        }
    }

    public var gridImportUnitPrice: Double {
        get { config.gridImportUnitPrice }
        set {
            config.gridImportUnitPrice = newValue
            appSettings.send(appSettings.value.copy(
                feedInUnitPrice: config.gridImportUnitPrice
            ))
        }
    }

    public var showInverterTemperature: Bool {
        get { config.showInverterTemperature }
        set {
            config.showInverterTemperature = newValue
            appSettings.send(appSettings.value.copy(
                showInverterTemperature: config.showInverterTemperature
            ))
        }
    }

    public var showInverterTypeNameOnPowerFlow: Bool {
        get { config.showInverterTypeNameOnPowerFlow }
        set {
            config.showInverterTypeNameOnPowerFlow = newValue
            appSettings.send(appSettings.value.copy(
                showInverterTypeNameOnPowerFlow: config.showInverterTypeNameOnPowerFlow
            ))
        }
    }

    public var solarDefinitions: SolarRangeDefinitions {
        get { config.solarDefinitions }
        set {
            config.solarDefinitions = newValue
            appSettings.send(appSettings.value.copy(
                solarDefinitions: config.solarDefinitions
            ))
        }
    }

    public var parameterGroups: [ParameterGroup] {
        get { config.parameterGroups }
        set {
            config.parameterGroups = newValue
            appSettings.send(appSettings.value.copy(
                parameterGroups: config.parameterGroups
            ))
        }
    }

    public var showGraphValueDescriptions: Bool {
        get { config.showGraphValueDescriptions }
        set {
            config.showGraphValueDescriptions = newValue
            appSettings.send(appSettings.value.copy(
                showGraphValueDescriptions: config.showGraphValueDescriptions
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

    public var selectedParameterGraphVariables: [String] {
        get { config.selectedParameterGraphVariables }
        set {
            config.selectedParameterGraphVariables = newValue
        }
    }

    public var showHomeTotalOnPowerFlow: Bool {
        get { config.showHomeTotalOnPowerFlow }
        set {
            config.showHomeTotalOnPowerFlow = newValue
            appSettings.send(appSettings.value.copy(
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow
            ))
        }
    }

    public var showInverterIcon: Bool {
        get { config.showInverterIcon }
        set {
            config.showInverterIcon = newValue
            appSettings.send(appSettings.value.copy(
                showInverterIcon: config.showInverterIcon
            ))
        }
    }

    public var shouldInvertCT2: Bool {
        get { config.shouldInvertCT2 }
        set {
            config.shouldInvertCT2 = newValue
            appSettings.send(appSettings.value.copy(
                shouldInvertCT2: config.shouldInvertCT2
            ))
        }
    }

    public var showInverterPlantName: Bool {
        get { config.showInverterPlantName }
        set {
            config.showInverterPlantName = newValue
            appSettings.send(appSettings.value.copy(
                showInverterPlantName: config.showInverterPlantName
            ))
        }
    }

    public var showGridTotalsOnPowerFlow: Bool {
        get { config.showGridTotalsOnPowerFlow }
        set {
            config.showGridTotalsOnPowerFlow = newValue
            appSettings.send(appSettings.value.copy(
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow
            ))
        }
    }

    public var showLastUpdateTimestamp: Bool {
        get { config.showLastUpdateTimestamp }
        set {
            config.showLastUpdateTimestamp = newValue
            appSettings.send(appSettings.value.copy(
                showLastUpdateTimestamp: config.showLastUpdateTimestamp
            ))
        }
    }

    public var shouldCombineCT2WithPVPower: Bool {
        get { config.shouldCombineCT2WithPVPower }
        set {
            config.shouldCombineCT2WithPVPower = newValue
            appSettings.send(appSettings.value.copy(
                shouldCombineCT2WithPVPower: config.shouldCombineCT2WithPVPower
            ))
        }
    }

    public var solcastSettings: SolcastSettings {
        get { config.solcastSettings }
        set {
            config.solcastSettings = newValue
            appSettings.send(appSettings.value.copy(
                solcastSettings: config.solcastSettings
            ))
        }
    }
}

public enum BatteryResponseMapper {
    public static func map(battery: BatteryResponse, settings: BatterySettingsResponse) -> Device.Battery {
        let batteryCapacity: String
        let minSOC: String

        if battery.soc > 0 {
            batteryCapacity = String(Int(battery.residual / (Double(battery.soc) / 100.0)))
        } else {
            batteryCapacity = "0"
        }
        minSOC = String(Double(settings.minGridSoc) / 100.0)

        return Device.Battery(capacity: batteryCapacity, minSOC: minSOC)
    }
}
