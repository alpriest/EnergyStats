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

    public func deleteScheduleTemplate(templateID: String) async throws {}

    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {}

    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
        ScheduleTemplateResponse(
            templateName: "Template-1",
            enable: false,
            pollcy: [SchedulePollcy(startH: 15, startM: 0, endH: 17, endM: 0, fdpwr: 0, workMode: "ForceCharge", fdsoc: 100, minsocongrid: 100),
                     SchedulePollcy(startH: 17, startM: 0, endH: 18, endM: 30, fdpwr: 3500, workMode: "ForceDischarge", fdsoc: 20, minsocongrid: 20)],
            content: "Description of template 1"
        )
    }

    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {}

    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
        ScheduleTemplateListResponse(data: [
            .init(templateName: "Winter charging", enable: false, templateID: "a"),
            .init(templateName: "Saving session", enable: false, templateID: "b"),
            .init(templateName: "Summer usage", enable: false, templateID: "c")
        ])
    }

    public func createScheduleTemplate(name: String, description: String) async throws {}
    public func deleteSchedule(deviceSN: String) async throws {}
    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {}

    public func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse {
        ScheduleListResponse(
            data: [
                ScheduleTemplateSummaryResponse(templateName: "Winter charging", enable: false, templateID: "123"),
                ScheduleTemplateSummaryResponse(templateName: "", enable: true, templateID: "")
            ],
            enable: true,
            pollcy: [
                SchedulePollcy(startH: 15, startM: 0, endH: 17, endM: 0, fdpwr: 0, workMode: "ForceCharge", fdsoc: 100, minsocongrid: 100),
                SchedulePollcy(startH: 17, startM: 0, endH: 18, endM: 30, fdpwr: 3500, workMode: "ForceDischarge", fdsoc: 20, minsocongrid: 20)
            ]
        )
    }

    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
        [
            SchedulerModeResponse(color: "#80F6BD16", name: "Back Up", key: "Backup"),
            SchedulerModeResponse(color: "#805B8FF9", name: "Feed-in Priority", key: "Feedin"),
            SchedulerModeResponse(color: "#80BBE9FB", name: "Force Charge", key: "ForceCharge"),
            SchedulerModeResponse(color: "#8065789B", name: "Force Discharge", key: "ForceDischarge"),
            SchedulerModeResponse(color: "#8061DDAA", name: "Self-Use", key: "SelfUse")
        ]
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        SchedulerFlagResponse(enable: true, support: true)
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        switch deviceID {
        case "f3000-deviceid":
            return BatteryResponse(power: 0.28, soc: 76, residual: 7550, temperature: 17.3)
        default:
            return BatteryResponse(power: 0.78, soc: 46, residual: 17510, temperature: 19.3)
        }
    }

    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        switch deviceSN {
        case "1234":
            return BatterySettingsResponse(minGridSoc: 20, minSoc: 20)
        default:
            return BatterySettingsResponse(minGridSoc: 15, minSoc: 15)
        }
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        [
            DeviceDetailResponse(
                deviceSN: "5678",
                moduleSN: "sn-1",
                plantID: "p1",
                stationName: "station 1",
                managerVersion: "1.0",
                masterVersion: "2.0",
                slaveVersion: "3.0",
                hardwareVersion: "4.0",
                status: 1,
                function: DeviceDetailResponse.Function(scheduler: false)
            ),
            DeviceDetailResponse(
                deviceSN: "1234",
                moduleSN: "sn-2",
                plantID: "p2",
                stationName: "station 2",
                managerVersion: "1.0",
                masterVersion: "2.0",
                slaveVersion: "3.0",
                hardwareVersion: "4.0",
                status: 1,
                function: DeviceDetailResponse.Function(scheduler: false)
            )
        ]
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.foxServerError(0, "Fake thrown error")
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

        let response = try JSONDecoder().decode(NetworkResponse<[ReportResponse]>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        if throwOnCall {
            throw NetworkError.foxServerError(0, "Fake thrown error")
        }

        let data = try data(filename: "raw-\(deviceID)")
        let response = try JSONDecoder().decode(NetworkResponse<[RawResponse]>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.map {
            RawResponse(variable: $0.variable, data: $0.data.map {
                let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)

                let date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: Date())

                return RawResponse.ReportData(time: date ?? $0.time, value: $0.value)
            })
        }
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        AddressBookResponse(softVersion: AddressBookResponse.SoftwareVersion(master: "1.54", slave: "1.02", manager: "1.57"))
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        let data = try data(filename: "variables")
        let response = try JSONDecoder().decode(NetworkResponse<VariablesResponse>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.variables
    }

    private func data(filename: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    public func setSoc(minGridSOC: Int, minSOC: Int, deviceSN: String) async throws {}

    public func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        BatteryTimesResponse(sn: "ABC1234", times: [
            ChargeTime(enableGrid: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
            ChargeTime(enableGrid: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))
        ])
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {}

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        DeviceSettingsGetResponse(protocol: "H1234", raw: "", values: InverterValues(operationModeWorkMode: .feedInFirst))
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {}

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        PagedDataLoggerListResponse(currentPage: 1, pageSize: 10, total: 1, data: [
            PagedDataLoggerListResponse.DataLogger(moduleSN: "ABC123DEF456", moduleType: "W2", plantName: "John Doe", version: "3.08", signal: 3, communication: 1),
            PagedDataLoggerListResponse.DataLogger(moduleSN: "123DEF456ABC", moduleType: "W2", plantName: "Jane Doe", version: "3.08", signal: 1, communication: 0)
        ])
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

    public func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse {
        OpenHistoryResponse(deviceSN: deviceSN, datas: [])
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        []
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        []
    }
}

public class MockConfig: Config {
    public init() {}
    public func clear() {}

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
    public var financialModel: Int = FinancialModel.energyStats.rawValue
    public var gridImportUnitPrice: Double = 0.15
    public var feedInUnitPrice: Double = 0.05
    public var showInverterTemperature: Bool = false
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
    public var totalSolarYieldModel: Int = 0
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
