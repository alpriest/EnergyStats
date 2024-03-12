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
    func fetchPowerStationDetail() async throws
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
    var showInverterTypeName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
    var currencySymbol: String { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var shouldCombineCT2WithLoadsPower: Bool { get set }
    var showGraphValueDescriptions: Bool { get set }
    var dataCeiling: DataCeiling { get set }
    var showTotalYieldOnPowerFlow: Bool { get set }
    var showFinancialSummaryOnFlowPage: Bool { get set }
    var separateParameterGraphsByUnit: Bool { get set }
    var useTraditionalLoadFormula: Bool { get set }
    var powerFlowStrings: PowerFlowStringsSettings { get set }
    var showBatteryPercentageRemaining: Bool { get set }
    var powerStationDetail: PowerStationDetail? { get }
}

public protocol SolcastConfigManaging {
    var solcastSettings: SolcastSettings { get set }
}

public protocol FinancialConfigManaging {
    var showFinancialEarnings: Bool { get set }
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
}

public struct PowerFlowStringsSettings: Codable {
    public let enabled: Bool
    public let pv1Name: String
    public let pv1Enabled: Bool
    public let pv2Name: String
    public let pv2Enabled: Bool
    public let pv3Name: String
    public let pv3Enabled: Bool
    public let pv4Name: String
    public let pv4Enabled: Bool

    public func variableNames() -> [String] {
        guard enabled else { return [] }
        var variables = [String]()

        if pv1Enabled {
            variables.append("pv1Power")
        }

        if pv2Enabled {
            variables.append("pv2Power")
        }

        if pv3Enabled {
            variables.append("pv3Power")
        }

        if pv4Enabled {
            variables.append("pv4Power")
        }

        return variables
    }

    public func makeStringPowers(from response: OpenQueryResponse) -> [StringPower] {
        guard enabled else { return [] }
        var strings = [StringPower]()

        if pv1Enabled {
            strings.append(StringPower(name: "PV1", amount: abs(response.datas.currentValue(for: "pv1Power"))))
        }

        if pv2Enabled {
            strings.append(StringPower(name: "PV2", amount: abs(response.datas.currentValue(for: "pv2Power"))))
        }

        if pv3Enabled {
            strings.append(StringPower(name: "PV3", amount: abs(response.datas.currentValue(for: "pv3Power"))))
        }

        if pv4Enabled {
            strings.append(StringPower(name: "PV4", amount: abs(response.datas.currentValue(for: "pv4Power"))))
        }

        return strings
    }

    public func copy(
        enabled: Bool? = nil,
        pv1Name: String? = nil,
        pv1Enabled: Bool? = nil,
        pv2Name: String? = nil,
        pv2Enabled: Bool? = nil,
        pv3Name: String? = nil,
        pv3Enabled: Bool? = nil,
        pv4Name: String? = nil,
        pv4Enabled: Bool? = nil) -> PowerFlowStringsSettings
    {
        PowerFlowStringsSettings(
            enabled: enabled ?? self.enabled,
            pv1Name: pv1Name ?? self.pv1Name,
            pv1Enabled: pv1Enabled ?? self.pv1Enabled,
            pv2Name: pv2Name ?? self.pv2Name,
            pv2Enabled: pv2Enabled ?? self.pv2Enabled,
            pv3Name: pv3Name ?? self.pv3Name,
            pv3Enabled: pv3Enabled ?? self.pv3Enabled,
            pv4Name: pv4Name ?? self.pv4Name,
            pv4Enabled: pv4Enabled ?? self.pv4Enabled)
    }

    public static var none: PowerFlowStringsSettings {
        PowerFlowStringsSettings(
            enabled: false,
            pv1Name: "PV1",
            pv1Enabled: false,
            pv2Name: "PV2",
            pv2Enabled: false,
            pv3Name: "PV3",
            pv3Enabled: false,
            pv4Name: "PV4",
            pv4Enabled: false)
    }
}
