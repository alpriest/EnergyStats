//
//  ConfigManaging.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/01/2024.
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
    func logout(clearDisplaySettings: Bool, clearDeviceSettings: Bool)
    func select(device: Device?)
    func clearBatteryOverride(for deviceID: String)
    var appSettingsPublisher: LatestAppSettingsPublisher { get }

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
    var refreshFrequency: RefreshFrequency { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var selectedDeviceSN: String? { get }
    var firmwareVersions: DeviceFirmwareVersion? { get }
    var displayUnit: DisplayUnit { get set }
    var variables: [Variable] { get }
    var currentDevice: CurrentValueSubject<Device?, Never> { get }
    var hasBattery: Bool { get }
    var showInverterTemperature: Bool { get set }
    var selectedParameterGraphVariables: [String] { get set }
    var showHomeTotalOnPowerFlow: Bool { get set }
    var showInverterIcon: Bool { get set }
    var shouldInvertCT2: Bool { get set }
    var showInverterStationName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
    var currencySymbol: String { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var showGraphValueDescriptions: Bool { get set }
    var dataCeiling: DataCeiling { get set }
    var showTotalYieldOnPowerFlow: Bool { get set }
    var showFinancialSummaryOnFlowPage: Bool { get set }
    var separateParameterGraphsByUnit: Bool { get set }
}

public protocol SolcastConfigManaging {
    var solcastSettings: SolcastSettings { get set }
}

public protocol FinancialConfigManaging {
    var showFinancialEarnings: Bool { get set }
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
}
