//
//  ConfigManager.swift
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

public enum ForcedColorScheme: Int, Codable {
    case auto = 0
    case light = 1
    case dark = 2
}

public protocol ConfigManaging: FinancialConfigManager, SolcastConfigManager, BatteryConfigManager, CurrentStatusCalculatorConfig, ScheduleTemplateConfigManager {
    func fetchPowerStationDetail() async throws
    func fetchDevices() async throws
    func logout(clearDisplaySettings: Bool, clearDeviceSettings: Bool)
    func select(device: Device?)
    var appSettingsPublisher: LatestAppSettingsPublisher { get }

    var hasRunBefore: Bool { get set }
    var minSOC: Double { get set }
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
    var showInverterStationName: Bool { get set }
    var showInverterTypeName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
    var currencySymbol: String { get set }
    var showGraphValueDescriptions: Bool { get set }
    var dataCeiling: DataCeiling { get set }
    var showTotalYieldOnPowerFlow: Bool { get set }
    var showFinancialSummaryOnFlowPage: Bool { get set }
    var separateParameterGraphsByUnit: Bool { get set }
    var showBatteryPercentageRemaining: Bool { get set }
    var powerStationDetail: PowerStationDetail? { get }
    var showSelfSufficiencyStatsGraphOverlay: Bool { get set }
    var truncatedYAxisOnParameterGraphs: Bool { get set }
    var summaryDateRange: SummaryDateRange { get set }
    var colorScheme: ForcedColorScheme { get set }
    var lastSolcastRefresh: Date? { get set }
    var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode { get set }
    var showInverterScheduleQuickLink: Bool { get set }
    var fetchSolcastOnAppLaunch: Bool { get set }
}

public protocol BatteryConfigManager {
    var batteryCapacity: String { get set }
    var batteryCapacityW: Int { get }
    var minSOC: Double { get }
    var showUsableBatteryOnly: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }

    func clearBatteryOverride(for deviceID: String)
}

public protocol SolcastConfigManager {
    var solcastSettings: SolcastSettings { get set }
}

public protocol FinancialConfigManager {
    var showFinancialEarnings: Bool { get set }
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
    var earningsModel: EarningsModel { get set }
}

public protocol ScheduleTemplateConfigManager {
    var scheduleTemplates: [ScheduleTemplate] { get set }
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
    public let pv5Name: String
    public let pv5Enabled: Bool
    public let pv6Name: String
    public let pv6Enabled: Bool

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

        if pv5Enabled {
            variables.append("pv5Power")
        }

        if pv6Enabled {
            variables.append("pv6Power")
        }

        return variables
    }

    public func makeStringPowers(from response: OpenQueryResponse) -> [StringPower] {
        guard enabled else { return [] }
        var strings = [StringPower]()

        if pv1Enabled {
            strings.append(StringPower(name: "PV1", amount: abs(response.datas.currentDouble(for: "pv1Power"))))
        }

        if pv2Enabled {
            strings.append(StringPower(name: "PV2", amount: abs(response.datas.currentDouble(for: "pv2Power"))))
        }

        if pv3Enabled {
            strings.append(StringPower(name: "PV3", amount: abs(response.datas.currentDouble(for: "pv3Power"))))
        }

        if pv4Enabled {
            strings.append(StringPower(name: "PV4", amount: abs(response.datas.currentDouble(for: "pv4Power"))))
        }

        if pv5Enabled {
            strings.append(StringPower(name: "PV5", amount: abs(response.datas.currentDouble(for: "pv5Power"))))
        }

        if pv6Enabled {
            strings.append(StringPower(name: "PV6", amount: abs(response.datas.currentDouble(for: "pv6Power"))))
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
        pv4Enabled: Bool? = nil,
        pv5Name: String? = nil,
        pv5Enabled: Bool? = nil,
        pv6Name: String? = nil,
        pv6Enabled: Bool? = nil
    ) -> PowerFlowStringsSettings {
        PowerFlowStringsSettings(
            enabled: enabled ?? self.enabled,
            pv1Name: pv1Name ?? self.pv1Name,
            pv1Enabled: pv1Enabled ?? self.pv1Enabled,
            pv2Name: pv2Name ?? self.pv2Name,
            pv2Enabled: pv2Enabled ?? self.pv2Enabled,
            pv3Name: pv3Name ?? self.pv3Name,
            pv3Enabled: pv3Enabled ?? self.pv3Enabled,
            pv4Name: pv4Name ?? self.pv4Name,
            pv4Enabled: pv4Enabled ?? self.pv4Enabled,
            pv5Name: pv5Name ?? self.pv5Name,
            pv5Enabled: pv5Enabled ?? self.pv5Enabled,
            pv6Name: pv6Name ?? self.pv6Name,
            pv6Enabled: pv6Enabled ?? self.pv6Enabled
        )
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
            pv4Enabled: false,
            pv5Name: "PV5",
            pv5Enabled: false,
            pv6Name: "PV6",
            pv6Enabled: false
        )
    }
}

public enum SummaryDateRange: Codable, Equatable {
    case automatic
    case manual(from: Date, to: Date)

    public static func == (lhs: SummaryDateRange, rhs: SummaryDateRange) -> Bool {
        switch (lhs, rhs) {
        case (.automatic, .automatic): return true
        default: return false
        }
    }
}

public enum BatteryTemperatureDisplayMode: Int, Codable, Equatable {
    case automatic = 0
    case battery1 = 1
    case battery2 = 2
}
