//
//  DemoNetworking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Foundation

public class DemoNetworking: FoxESSNetworking {
    private let throwOnCall: Bool

    public init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
    }

    public func ensureHasToken() async {
        // Do nothing
    }

    public func verifyCredentials(username: String, hashedPassword: String) async throws {
        // Assume mock credentials are valid
    }

//    public func deleteScheduleTemplate(templateID: String) async throws {}
//
//    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {}
//
//    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
//        ScheduleTemplateResponse(
//            templateName: "Template-1",
//            enable: false,
//            pollcy: [SchedulePollcy(startH: 15, startM: 0, endH: 17, endM: 0, fdpwr: 0, workMode: "ForceCharge", fdsoc: 100, minsocongrid: 100),
//                     SchedulePollcy(startH: 17, startM: 0, endH: 18, endM: 30, fdpwr: 3500, workMode: "ForceDischarge", fdsoc: 20, minsocongrid: 20)],
//            content: "Description of template 1"
//        )
//    }
//
//    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {}
//
//    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
//        ScheduleTemplateListResponse(data: [
//            .init(templateName: "Winter charging", enable: false, templateID: "a"),
//            .init(templateName: "Saving session", enable: false, templateID: "b"),
//            .init(templateName: "Summer usage", enable: false, templateID: "c")
//        ])
//    }
//
//    public func createScheduleTemplate(name: String, description: String) async throws {}
//    public func deleteSchedule(deviceSN: String) async throws {}
//    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {}
//
//    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
//        [
//            SchedulerModeResponse(color: "#80F6BD16", name: "Back Up", key: "Backup"),
//            SchedulerModeResponse(color: "#805B8FF9", name: "Feed-in Priority", key: "Feedin"),
//            SchedulerModeResponse(color: "#80BBE9FB", name: "Force Charge", key: "ForceCharge"),
//            SchedulerModeResponse(color: "#8065789B", name: "Force Discharge", key: "ForceDischarge"),
//            SchedulerModeResponse(color: "#8061DDAA", name: "Self-Use", key: "SelfUse")
//        ]
//    }

    public func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        GetSchedulerFlagResponse(enable: true, support: true)
    }

    public func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        switch deviceSN {
        case "1234":
            return BatterySOCResponse(minSocOnGrid: 20, minSoc: 20)
        default:
            return BatterySOCResponse(minSocOnGrid: 15, minSoc: 15)
        }
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        [
            DeviceDetailResponse(
                deviceSN: "5678",
                moduleSN: "sn-1",
                stationID: "p1",
                stationName: "station 1",
                managerVersion: "1.0",
                masterVersion: "2.0",
                slaveVersion: "3.0",
                hardwareVersion: "4.0",
                status: 1,
                function: DeviceDetailResponse.Function(scheduler: false),
                productType: "H",
                deviceType: "h1-3.0",
                hasBattery: true,
                hasPV: true
            ),
            DeviceDetailResponse(
                deviceSN: "1234",
                moduleSN: "sn-2",
                stationID: "p2",
                stationName: "station 2",
                managerVersion: "1.0",
                masterVersion: "2.0",
                slaveVersion: "3.0",
                hardwareVersion: "4.0",
                status: 1,
                function: DeviceDetailResponse.Function(scheduler: false),
                productType: "H",
                deviceType: "h1-5.0",
                hasBattery: true,
                hasPV: false
            )
        ]
    }

    private func data(filename: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    public func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {}

    public func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        [
            ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
            ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))
        ]
    }

    public func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {}

    public func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        [
            DataLoggerResponse(moduleSN: "ABC123DEF456", stationID: "John Doe 1", status: .online, signal: 3),
            DataLoggerResponse(moduleSN: "123DEF456ABC", stationID: "Jane Doe 2", status: .online, signal: 1)
        ]
    }

    public func fetchErrorMessages() async {}

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        OpenQueryResponse(time: Date(),
                          deviceSN: deviceSN,
                          datas: [
                              OpenQueryResponse.Data(unit: "kW", variable: "feedinPower", value: 0.0),
                              OpenQueryResponse.Data(unit: "kW", variable: "gridConsumptionPower", value: 2.634),
                              OpenQueryResponse.Data(unit: "kW", variable: "loadsPower", value: 2.708),
                              OpenQueryResponse.Data(unit: "kW", variable: "generationPower", value: 0.071),
                              OpenQueryResponse.Data(unit: "kW", variable: "pvPower", value: 0.111),
                              OpenQueryResponse.Data(unit: "kW", variable: "meterPower2", value: 0.0),
                              OpenQueryResponse.Data(unit: "℃", variable: "ambientTemperation", value: 32.5),
                              OpenQueryResponse.Data(unit: "℃", variable: "invTemperation", value: 23.2)
                          ])
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        OpenHistoryResponse(deviceSN: deviceSN, datas: [])
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        []
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
//        if throwOnCall {
//            throw NetworkError.foxServerError(0, "Fake thrown error")
//        }
//
//        let data: Data
//        switch reportType {
//        case .day:
//            data = try self.data(filename: "report-day")
//        case .month:
//            data = try self.data(filename: "report-month")
//        case .year:
//            data = try self.data(filename: "report-year")
//        }
//
//        let response = try JSONDecoder().decode(NetworkResponse<[ReportResponse]>.self, from: data)
//        guard let result = response.result else { throw NetworkError.invalidToken }
//
//        return result
        []
    }

    public func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        ScheduleResponse(
            enable: 0,
            groups: [
                SchedulePhaseResponse(
                    enable: 1,
                    startHour: 15,
                    startMinute: 0,
                    endHour: 17,
                    endMinute: 0,
                    workMode: .ForceCharge,
                    minSocOnGrid: 20,
                    fdSoc: 100,
                    fdPwr: 0
                ),
                SchedulePhaseResponse(
                    enable: 1,
                    startHour: 17,
                    startMinute: 0,
                    endHour: 18,
                    endMinute: 30,
                    workMode: .ForceDischarge,
                    minSocOnGrid: 20,
                    fdSoc: 20,
                    fdPwr: 3500
                )
            ]
        )
    }

    public func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {}
    public func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {}
}

public class MockConfig: Config {
    public init() {}
    public func clearDisplaySettings() {}
    public func clearDeviceSettings() {}

    public var showGraphValueDescriptions: Bool = true
    public var showBatteryEstimate: Bool = true
    public var batteryCapacity: String?
    public var minSOC: String?
    public var deviceID: String?
    public var deviceSN: String?
    public var hasBattery: Bool = true
    public var hasPV: Bool = true
    public var isDemoUser: Bool = true
    public var hasRunBefore: Bool = true
    public var showColouredLines: Bool = true
    public var showBatteryTemperature: Bool = true
    public var refreshFrequency: Int = 0
    public var decimalPlaces: Int = 3
    public var showSunnyBackground: Bool = true
    public var devices: Data?
    public var selectedDeviceSN: String?
    public var showUsableBatteryOnly: Bool = false
    public var displayUnit: Int = 0
    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .off
    public var showFinancialEarnings: Bool = false
    public var gridImportUnitPrice: Double = 0.15
    public var feedInUnitPrice: Double = 0.05
    public var showInverterTemperature: Bool = false
    public var showInverterTypeName: Bool = false
    public var selectedParameterGraphVariables: [String] = []
    public var showHomeTotalOnPowerFlow: Bool = true
    public var showInverterIcon: Bool = true
    public var shouldInvertCT2: Bool = true
    public var showInverterStationName: Bool = false
    public var showGridTotalsOnPowerFlow: Bool = false
    public var deviceBatteryOverrides: [String: String] = [:]
    public var showLastUpdateTimestamp: Bool = false
    public var solarDefinitions: SolarRangeDefinitions = .default()
    public var parameterGroups: [ParameterGroup] = DefaultParameterGroups()
    public var currencySymbol: String = "£"
    public var shouldCombineCT2WithPVPower: Bool = true
    public var solcastSettings: SolcastSettings = .init(apiKey: nil, sites: [SolcastSite.preview()])
    public var dataCeiling: DataCeiling = .mild
    public var showTotalYieldOnPowerFlow: Bool = true
    public var showFinancialSummaryOnFlowPage: Bool = true
    public var separateParameterGraphsByUnit: Bool = true
    public var variables: [Variable] = []
}

public class PreviewConfigManager: ConfigManager {
    public convenience init() {
        self.init(networking: DemoNetworking(), config: MockConfig(), appSettingsPublisher: CurrentValueSubject(AppSettings.mock()))
        Task { try await fetchDevices() }
    }
}

public extension SolcastSite {
    static func preview() -> SolcastSite {
        SolcastSite(
            name: "Front panels",
            resourceId: "abc-123-def-456",
            lng: -2.470923,
            lat: 53.377811,
            azimuth: 134,
            tilt: 45,
            lossFactor: 0.9,
            acCapacity: 3.7,
            dcCapacity: 5.6,
            installDate: Date()
        )
    }
}
