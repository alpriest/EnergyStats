//
//  ConfigManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2023.
//

import Combine
import Foundation
import os
import WidgetKit

public class ConfigManager: ConfigManaging {
    private let networking: Networking
    private var keychainStore: KeychainStoring
    private var config: StoredConfig
    public var appSettingsPublisher: AnyPublisher<AppSettings, Never> { appSettingsStore.publisher }
    public var currentDevice = CurrentValueSubject<Device?, Never>(nil)
    private var deviceSupportsScheduleMaxSOC: [String: Bool] = [:] // In-memory only
    private var deviceSupportsPeakShaving: [String: Bool] = [:] // In-memory only
    public var lastSettingsResetTime = CurrentValueSubject<Date?, Never>(nil)
    private var fetchDeviceLock = OSAllocatedUnfairLock()
    private var isFetching = false
    private let appSettingsStore: AppSettingsStore
    public var currentAppSettings: AppSettings { appSettingsStore.currentValue }

    public struct NoDeviceFoundError: Error {
        public init() {}
    }

    public struct NoBattery: Error {
        public init() {}
    }

    public init(networking: Networking, config: StoredConfig, appSettingsStore: AppSettingsStore, keychainStore: KeychainStoring) {
        self.networking = networking
        self.config = config
        self.appSettingsStore = appSettingsStore
        self.keychainStore = keychainStore
        selectedDeviceSN = selectedDeviceSN // force the currentDevice to be set
    }

    public func fetchPowerStationDetail() async throws {
        let detail = try await networking.fetchPowerStationDetail()
        config.powerStationDetail = detail
    }

    public func fetchDevices() async throws {
        // Attempt to acquire the fetch; bail out if another fetch is in-flight
        let shouldStart: Bool = fetchDeviceLock.withLock {
            if isFetching { return false }
            isFetching = true
            return true
        }
        guard shouldStart else { return }

        // Ensure we always clear the flag, even on early returns or thrown errors
        defer {
            fetchDeviceLock.withLock { isFetching = false }
        }

        let deviceList = try await networking.fetchDeviceList()
        config.variables = try await networking.fetchVariables().compactMap {
            guard let unit = $0.unit else { return nil }
            return Variable(name: $0.name, variable: $0.variable, unit: unit)
        }

        guard !deviceList.isEmpty else {
            throw NoDeviceFoundError()
        }

        let newDevices = try await deviceList.asyncMap { device in
            try await loadDevice(device: device)
        }
        devices = newDevices

        if selectedDeviceSN == nil {
            select(device: devices?.first)
        } else if currentDevice.value == nil {
            select(device: devices?.first(where: { $0.deviceSN == selectedDeviceSN }))
        }
    }

    func loadDevice(device: DeviceSummaryResponse) async throws -> Device {
        let deviceBattery: Device.Battery?

        if device.hasBattery {
            do {
                let batteryVariables = try await networking.fetchRealData(deviceSN: device.deviceSN, variables: ["ResidualEnergy", "SoC", "SoC_1"])
                let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)
                let batteryDetail = try await networking.fetchDevice(deviceSN: device.deviceSN)

                deviceBattery = BatteryResponseMapper.map(
                    batteryVariables: batteryVariables,
                    socResponse: batterySettings,
                    modules: batteryDetail.batteryList
                )
            } catch {
                deviceBattery = nil
            }
        } else {
            deviceBattery = nil
        }

        return Device(
            deviceSN: device.deviceSN,
            stationName: device.stationName,
            stationID: device.stationID,
            battery: deviceBattery,
            moduleSN: device.moduleSN,
            deviceType: device.deviceType,
            hasPV: device.hasPV,
            hasBattery: device.hasBattery,
            productType: device.productType
        )
    }

    public func logout(clearDisplaySettings: Bool, clearDeviceSettings: Bool) {
        if clearDisplaySettings {
            config.clearDisplaySettings()
        }

        if clearDeviceSettings {
            config.clearDeviceSettings()
            selectedDeviceSN = nil
        }
    }
    
    public func loginAsDemo() {
        appSettingsStore.update(.mock())
    }

    public func resetDisplaySettings() {
        config.clearDisplaySettings()
        appSettingsStore.update(AppSettings.make(from: self))
        lastSettingsResetTime.send(.now)
    }

    public func select(device: Device?) {
        guard let device else { return }

        selectedDeviceSN = device.deviceSN
    }

    public var minSOC: Double {
        get {
            guard let battery = currentDevice.value?.battery else { return 0.0 }
            return Double(battery.minSOC ?? "0.0") ?? 0.0
        }
        set {
            guard let device = currentDevice.value else { return }
            guard let battery = device.battery else { return }

            let updatedDevice = device.copy(battery: battery.copy(minSOC: newValue.roundedToString(decimalPlaces: 2)))
            devices = devices?.map {
                $0.deviceSN == device.deviceSN ? updatedDevice : $0
            }
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                minSOC: newValue
            ))
        }
    }

    public var variables: [Variable] {
        config.variables
    }

    public var batteryCapacity: String {
        get {
            if let currentDevice = currentDevice.value {
                let override = config.deviceBatteryOverrides[currentDevice.deviceSN]

                return override ?? currentDevice.battery?.capacity ?? "0"
            } else {
                return "0"
            }
        }
        set {
            if let currentDevice = currentDevice.value {
                config.deviceBatteryOverrides[currentDevice.deviceSN] = newValue
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

    public var selectedDeviceSN: String? {
        get {
            if devices?.first(where: { $0.deviceSN == config.selectedDeviceSN }) != nil {
                return config.selectedDeviceSN
            } else {
                config.selectedDeviceSN = devices?.first?.deviceSN
                return config.selectedDeviceSN
            }
        }
        set {
            config.selectedDeviceSN = newValue
            try? keychainStore.store(key: .deviceSN, value: newValue)
            currentDevice.send(devices?.first(where: { $0.deviceSN == selectedDeviceSN }) ?? devices?.first)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public var currencySymbol: String {
        get { config.currencySymbol }
        set {
            config.currencySymbol = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                currencySymbol: config.currencySymbol
            ))
        }
    }

    public var isDemoUser: Bool {
        get { config.isDemoUser }
        set {
            config.isDemoUser = newValue
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public var showColouredLines: Bool {
        get { config.showColouredLines }
        set {
            config.showColouredLines = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    public var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    public var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showBatteryEstimate: config.showBatteryEstimate
            ))
        }
    }

    public var showUsableBatteryOnly: Bool {
        get { config.showUsableBatteryOnly }
        set {
            config.showUsableBatteryOnly = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showUsableBatteryOnly: config.showUsableBatteryOnly
            ))
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public var refreshFrequency: RefreshFrequency {
        get { RefreshFrequency(rawValue: config.refreshFrequency) ?? .AUTO }
        set {
            config.refreshFrequency = newValue.rawValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                refreshFrequency: refreshFrequency
            ))
        }
    }

    public var showSunnyBackground: Bool {
        get { config.showSunnyBackground }
        set {
            config.showSunnyBackground = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get { config.selfSufficiencyEstimateMode }
        set {
            config.selfSufficiencyEstimateMode = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode
            ))
        }
    }

    public var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    public var displayUnit: DisplayUnit {
        get { DisplayUnit(rawValue: config.displayUnit) ?? .kilowatt }
        set {
            config.displayUnit = newValue.rawValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                displayUnit: newValue
            ))
        }
    }

    public var showFinancialEarnings: Bool {
        get { config.showFinancialEarnings }
        set {
            config.showFinancialEarnings = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showFinancialEarnings: config.showFinancialEarnings
            ))
        }
    }

    public var showFinancialSummaryOnFlowPage: Bool {
        get { config.showFinancialSummaryOnFlowPage }
        set {
            config.showFinancialSummaryOnFlowPage = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showFinancialSummaryOnFlowPage: config.showFinancialSummaryOnFlowPage
            ))
        }
    }

    public var feedInUnitPrice: Double {
        get { config.feedInUnitPrice }
        set {
            config.feedInUnitPrice = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                feedInUnitPrice: config.feedInUnitPrice
            ))
        }
    }

    public var gridImportUnitPrice: Double {
        get { config.gridImportUnitPrice }
        set {
            config.gridImportUnitPrice = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                feedInUnitPrice: config.gridImportUnitPrice
            ))
        }
    }

    public var showInverterTemperature: Bool {
        get { config.showInverterTemperature }
        set {
            config.showInverterTemperature = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterTemperature: config.showInverterTemperature
            ))
        }
    }

    public var solarDefinitions: SolarRangeDefinitions {
        get { config.solarDefinitions }
        set {
            config.solarDefinitions = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                solarDefinitions: config.solarDefinitions
            ))
        }
    }

    public var parameterGroups: [ParameterGroup] {
        get { config.parameterGroups }
        set {
            config.parameterGroups = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                parameterGroups: config.parameterGroups
            ))
        }
    }

    public var showGraphValueDescriptions: Bool {
        get { config.showGraphValueDescriptions }
        set {
            config.showGraphValueDescriptions = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
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
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow
            ))
        }
    }

    public var showInverterIcon: Bool {
        get { config.showInverterIcon }
        set {
            config.showInverterIcon = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterIcon: config.showInverterIcon
            ))
        }
    }

    public var shouldInvertCT2: Bool {
        get { config.shouldInvertCT2 }
        set {
            config.shouldInvertCT2 = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                shouldInvertCT2: config.shouldInvertCT2
            ))
        }
    }

    public var showInverterStationName: Bool {
        get { config.showInverterStationName }
        set {
            config.showInverterStationName = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterStationName: config.showInverterStationName
            ))
        }
    }

    public var showInverterTypeName: Bool {
        get { config.showInverterTypeName }
        set {
            config.showInverterTypeName = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterTypeName: config.showInverterTypeName
            ))
        }
    }

    public var showGridTotalsOnPowerFlow: Bool {
        get { config.showGridTotalsOnPowerFlow }
        set {
            config.showGridTotalsOnPowerFlow = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow
            ))
        }
    }

    public var showLastUpdateTimestamp: Bool {
        get { config.showLastUpdateTimestamp }
        set {
            config.showLastUpdateTimestamp = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showLastUpdateTimestamp: config.showLastUpdateTimestamp
            ))
        }
    }

    public var shouldCombineCT2WithPVPower: Bool {
        get { config.shouldCombineCT2WithPVPower }
        set {
            config.shouldCombineCT2WithPVPower = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                shouldCombineCT2WithPVPower: config.shouldCombineCT2WithPVPower
            ))
        }
    }

    public var solcastSettings: SolcastSettings {
        get { config.solcastSettings }
        set {
            config.solcastSettings = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                solcastSettings: config.solcastSettings
            ))
        }
    }

    public var dataCeiling: DataCeiling {
        get { config.dataCeiling }
        set {
            config.dataCeiling = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                dataCeiling: config.dataCeiling
            ))
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public var showTotalYieldOnPowerFlow: Bool {
        get { config.showTotalYieldOnPowerFlow }
        set {
            config.showTotalYieldOnPowerFlow = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showTotalYieldOnPowerFlow: showTotalYieldOnPowerFlow
            ))
        }
    }

    public var separateParameterGraphsByUnit: Bool {
        get { config.separateParameterGraphsByUnit }
        set {
            config.separateParameterGraphsByUnit = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                separateParameterGraphsByUnit: config.separateParameterGraphsByUnit
            ))
        }
    }

    public var powerFlowStrings: PowerFlowStringsSettings {
        get { config.powerFlowStrings }
        set {
            config.powerFlowStrings = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                powerFlowStrings: powerFlowStrings
            ))
        }
    }

    public var showBatteryPercentageRemaining: Bool {
        get { config.showBatteryPercentageRemaining }
        set {
            config.showBatteryPercentageRemaining = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showBatteryPercentageRemaining: config.showBatteryPercentageRemaining
            ))
        }
    }

    public var powerStationDetail: PowerStationDetail? { config.powerStationDetail }

    public var showSelfSufficiencyStatsGraphOverlay: Bool {
        get { config.showSelfSufficiencyStatsGraphOverlay }
        set {
            config.showSelfSufficiencyStatsGraphOverlay = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showSelfSufficiencyStatsGraphOverlay: config.showSelfSufficiencyStatsGraphOverlay
            ))
        }
    }

    public var scheduleTemplates: [ScheduleTemplate] {
        get { config.scheduleTemplates }
        set { config.scheduleTemplates = newValue }
    }

    public var truncatedYAxisOnParameterGraphs: Bool {
        get { config.truncatedYAxisOnParameterGraphs }
        set {
            config.truncatedYAxisOnParameterGraphs = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                truncatedYAxisOnParameterGraphs: config.truncatedYAxisOnParameterGraphs
            ))
        }
    }

    public var earningsModel: EarningsModel {
        get { config.earningsModel }
        set {
            config.earningsModel = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                earningsModel: config.earningsModel
            ))
        }
    }

    public var summaryDateRange: SummaryDateRange {
        get { config.summaryDateRange }
        set { config.summaryDateRange = newValue }
    }

    public var colorScheme: ForcedColorScheme {
        get { config.colorScheme }
        set { config.colorScheme = newValue }
    }

    public var lastSolcastRefresh: Date? {
        get { config.lastSolcastRefresh }
        set { config.lastSolcastRefresh = newValue }
    }

    public var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode {
        get { config.batteryTemperatureDisplayMode }
        set {
            config.batteryTemperatureDisplayMode = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                batteryTemperatureDisplayMode: config.batteryTemperatureDisplayMode
            ))
        }
    }

    public var showInverterScheduleQuickLink: Bool {
        get { config.showInverterScheduleQuickLink }
        set {
            config.showInverterScheduleQuickLink = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterScheduleQuickLink: showInverterScheduleQuickLink
            ))
        }
    }

    public var fetchSolcastOnAppLaunch: Bool {
        get { config.fetchSolcastOnAppLaunch }
        set {
            config.fetchSolcastOnAppLaunch = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                fetchSolcastOnAppLaunch: config.fetchSolcastOnAppLaunch
            ))
        }
    }

    public var ct2DisplayMode: CT2DisplayMode {
        get { config.ct2DisplayMode }
        set {
            config.ct2DisplayMode = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                ct2DisplayMode: config.ct2DisplayMode
            ))
        }
    }

    public var shouldCombineCT2WithLoadsPower: Bool {
        get { config.shouldCombineCT2WithLoadsPower }
        set {
            config.shouldCombineCT2WithLoadsPower = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                shouldCombineCT2WithLoadsPower: config.shouldCombineCT2WithLoadsPower
            ))
        }
    }

    public func getDeviceSupports(capability: DeviceCapability, deviceSN: String) -> Bool {
        switch capability {
        case .scheduleMaxSOC:
            deviceSupportsScheduleMaxSOC[deviceSN] ?? false
        case .peakShaving:
            deviceSupportsPeakShaving[deviceSN] ?? false
        }
    }

    public func setDeviceSupports(capability: DeviceCapability, deviceSN: String) {
        switch capability {
        case .scheduleMaxSOC:
            deviceSupportsScheduleMaxSOC[deviceSN] = true
        case .peakShaving:
            deviceSupportsPeakShaving[deviceSN] = true
        }
    }

    public var showInverterConsumption: Bool {
        get { config.showInverterConsumption }
        set {
            config.showInverterConsumption = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showInverterConsumption: config.showInverterConsumption
            ))
        }
    }

    public var showBatterySOCOnDailyStats: Bool {
        get { config.showBatterySOCOnDailyStats }
        set {
            config.showBatterySOCOnDailyStats = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                showBatterySOCOnDailyStats: config.showBatterySOCOnDailyStats
            ))
        }
    }
    
    public var allowNegativeLoad: Bool {
        get { config.allowNegativeLoad }
        set {
            config.allowNegativeLoad = newValue
            appSettingsStore.update(appSettingsStore.currentValue.copy(
                allowNegativeLoad: config.allowNegativeLoad
            ))
        }
    }
    
    public var workModes: [WorkMode] {
        get { config.workModes }
        set { config.workModes = newValue }
    }
}

public enum BatteryResponseMapper {
    public static func map(batteryVariables: OpenQueryResponse, socResponse: BatterySOCResponse, modules: [DeviceBatteryResponse]?) -> Device.Battery? {
        guard let residual = batteryVariables.datas.current(for: "ResidualEnergy")?.value else { return nil }

        let batteryCapacity: String
        let minSOC: String
        let soc = batteryVariables.datas.SoC()

        if soc > 0 {
            batteryCapacity = String(Int((residual * 10.0) / (soc / 100.0)))
        } else {
            batteryCapacity = "0"
        }
        minSOC = String(Double(socResponse.minSocOnGrid) / 100.0)

        let modules = modules?.map { DeviceBatteryModule(batterySN: $0.batterySN, type: $0.type, version: $0.version) }

        return Device.Battery(capacity: batteryCapacity, minSOC: minSOC, modules: modules)
    }
}

public extension ConfigManager {
    static func preview(
        config: StoredConfig = MockConfig(),
        networking: Networking = NetworkService.preview(),
        appSettings: AppSettings = .mock()
    ) -> ConfigManaging {
        PreviewConfigManager(config: config, networking: networking, appSettings: appSettings)
    }

    internal class PreviewConfigManager: ConfigManager {
        convenience init(config: StoredConfig, networking: Networking, appSettings: AppSettings = .mock()) {
            self.init(
                networking: networking,
                config: config,
                appSettingsStore: AppSettingsStore(),
                keychainStore: KeychainStore.preview()
            )
            Task { try await fetchDevices() }
        }
    }
}

extension Bool {
    var stringValue: String {
        self ? "true" : "false"
    }
}

extension String {
    var boolValue: Bool {
        self == "true"
    }
}

extension Int {
    var stringValue: String {
        String(describing: self)
    }
}

extension Optional where Wrapped == String {
    var boolValue: Bool {
        guard let self else { return false }
        return self.boolValue
    }
}
