//
//  DemoNetworking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Foundation

class DemoNetworking: NetworkService {
    init(callsToThrow: Set<DemoAPIRequest> = Set()) {
        super.init(api: DemoAPI(callsToThrow: callsToThrow))
    }
}

public enum DemoAPIRequest {
    case openapi_fetchDeviceList
    case openapi_fetchDevice
    case openapi_fetchRealData
    case openapi_fetchHistory
    case openapi_fetchVariables
    case openapi_fetchReport
    case openapi_fetchBatterySettings
    case openapi_setBatterySoc
    case openapi_fetchBatteryTimes
    case openapi_setBatteryTimes
    case openapi_fetchDataLoggers
    case openapi_fetchSchedulerFlag
    case openapi_fetchCurrentSchedule
    case openapi_setScheduleFlag
    case openapi_saveSchedule
    case openapi_fetchPowerStationList
    case openapi_fetchPowerStationDetail
}

class DemoAPI: FoxAPIServicing {
    private let callsToThrow: Set<DemoAPIRequest>

    init(callsToThrow: Set<DemoAPIRequest> = Set()) {
        self.callsToThrow = callsToThrow
    }

    func fetchErrorMessages() async {}

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        if callsToThrow.contains(.openapi_fetchSchedulerFlag) {
            throw NetworkError.missingData
        }

        return GetSchedulerFlagResponse(enable: true, support: true)
    }

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        if callsToThrow.contains(.openapi_fetchBatterySettings) {
            throw NetworkError.missingData
        }

        switch deviceSN {
        case "1234":
            return BatterySOCResponse(minSocOnGrid: 20, minSoc: 20)
        default:
            return BatterySOCResponse(minSocOnGrid: 15, minSoc: 15)
        }
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        if callsToThrow.contains(.openapi_fetchDeviceList) {
            throw NetworkError.missingData
        }

        return [
            DeviceSummaryResponse(
                deviceSN: "5678",
                moduleSN: "sn-1",
                stationID: "p1",
                stationName: "Bloggs Home",
                productType: "H",
                deviceType: "h1-3.0",
                hasBattery: true,
                hasPV: true,
                status: 1
            ),
            DeviceSummaryResponse(
                deviceSN: "1234",
                moduleSN: "sn-2",
                stationID: "p2",
                stationName: "Bloggs Shed",
                productType: "H",
                deviceType: "h1-5.0",
                hasBattery: true,
                hasPV: false,
                status: 1
            )
        ]
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        if callsToThrow.contains(.openapi_fetchDevice) {
            throw NetworkError.missingData
        }

        return DeviceDetailResponse(
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
        )
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        if callsToThrow.contains(.openapi_setBatterySoc) {
            throw NetworkError.missingData
        }
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        if callsToThrow.contains(.openapi_fetchBatteryTimes) {
            throw NetworkError.missingData
        }

        return [
            ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
            ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))
        ]
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        if callsToThrow.contains(.openapi_setBatteryTimes) {
            throw NetworkError.missingData
        }
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        if callsToThrow.contains(.openapi_fetchDataLoggers) {
            throw NetworkError.missingData
        }

        return [
            DataLoggerResponse(moduleSN: "ABC123DEF456", stationID: "John Doe 1", status: .online, signal: 3),
            DataLoggerResponse(moduleSN: "123DEF456ABC", stationID: "Jane Doe 2", status: .online, signal: 1)
        ]
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        if callsToThrow.contains(.openapi_fetchRealData) {
            throw NetworkError.missingData
        }

        return OpenQueryResponse(time: Date(),
                                 deviceSN: deviceSN,
                                 datas: [
                                     OpenQueryResponse.Data(unit: "kW", variable: "feedinPower", value: 0.0, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "gridConsumptionPower", value: 2.634, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "loadsPower", value: 2.708, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "SoC", value: 65, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "batDischargePower", value: 0, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "batChargePower", value: 1.200, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "generationPower", value: 0.071, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "pvPower", value: 0.111, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "kW", variable: "meterPower2", value: 0.0, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "℃", variable: "ambientTemperation", value: 32.5, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "℃", variable: "invTemperation", value: 23.2, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "℃", variable: "batTemperature", value: 26.5, stringValue: nil),
                                     OpenQueryResponse.Data(unit: "0.01kWh", variable: "ResidualEnergy", value: 1087, stringValue: nil)
                                 ])
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        if callsToThrow.contains(.openapi_fetchHistory) {
            throw NetworkError.missingData
        }

        let data = try self.data(filename: "history-temp")
        let response = try JSONDecoder().decode(NetworkResponse<[OpenHistoryResponse]>.self, from: data)
        guard let result = response.result?.first else { throw NetworkError.invalidToken }

        return OpenHistoryResponse(deviceSN: result.deviceSN,
                                   datas: result.datas.map {
                                       OpenHistoryResponse.Data(
                                           unit: $0.unit,
                                           name: $0.name,
                                           variable: $0.variable,
                                           data: $0.data.map {
                                               let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)
                                               let date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: Date())

                                               return OpenHistoryResponse.Data.UnitData(
                                                   time: date ?? $0.time,
                                                   value: $0.value
                                               )
                                           }
                                       )
                                   })
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        if callsToThrow.contains(.openapi_fetchVariables) {
            throw NetworkError.missingData
        }

        let data = try self.data(filename: "variables")
        let response = try JSONDecoder().decode(NetworkResponse<OpenApiVariableArray>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }
        return result.array
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        if callsToThrow.contains(.openapi_fetchReport) {
            throw NetworkError.missingData
        }

        let data: Data
        switch reportType {
        case .day:
            data = try self.data(filename: "report-day")
        case .month:
            data = try self.data(filename: "report-month")
        case .year:
            data = try self.data(filename: "report-year")
        }

        let response = try JSONDecoder().decode(NetworkResponse<[OpenReportResponse]>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        if callsToThrow.contains(.openapi_fetchCurrentSchedule) {
            throw NetworkError.missingData
        }

        return ScheduleResponse(
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

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        if callsToThrow.contains(.openapi_setScheduleFlag) {
            throw NetworkError.missingData
        }
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        if callsToThrow.contains(.openapi_saveSchedule) {
            throw NetworkError.missingData
        }
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        if callsToThrow.contains(.openapi_fetchPowerStationList) {
            throw NetworkError.missingData
        }

        return PagedPowerStationListResponse(currentPage: 0, pageSize: 0, total: 0, data: [])
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        if callsToThrow.contains(.openapi_fetchPowerStationDetail) {
            throw NetworkError.missingData
        }

        return PowerStationDetailResponse(stationName: "station \(stationID)", capacity: 3500, timezone: "Europe/London")
    }

    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse {
        ApiRequestCountResponse(total: "10", remaining: "5")
    }

    private func data(filename: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
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
    public var selectedParameterGraphVariables: [String] = ["ambientTemperation", "invTemperation", "batTemperature"]
    public var showHomeTotalOnPowerFlow: Bool = false
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
    public var solcastSettings: SolcastSettings = .init(apiKey: "1234", sites: [SolcastSite.preview()])
    public var dataCeiling: DataCeiling = .mild
    public var showTotalYieldOnPowerFlow: Bool = true
    public var showFinancialSummaryOnFlowPage: Bool = true
    public var separateParameterGraphsByUnit: Bool = true
    public var variables: [Variable] = []
    public var powerFlowStrings: PowerFlowStringsSettings = .none
    public var showBatteryPercentageRemaining: Bool = true
    public var powerStationDetail: PowerStationDetail? = nil
    public var showSelfSufficiencyStatsGraphOverlay: Bool = true
    public var scheduleTemplates: [ScheduleTemplate] = []
    public var truncatedYAxisOnParameterGraphs: Bool = false
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
