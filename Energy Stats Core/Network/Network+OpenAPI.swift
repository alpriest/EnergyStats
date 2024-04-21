//
//  Network+OpenAPI.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/01/2024.
//

import Foundation

extension URL {
    static var getOpenRealData = URL(string: "https://www.foxesscloud.com/op/v0/device/real/query")!
    static var getOpenHistoryData = URL(string: "https://www.foxesscloud.com/op/v0/device/history/query")!
    static var getOpenVariables = URL(string: "https://www.foxesscloud.com/op/v0/device/variable/get")!
    static var getOpenReportData = URL(string: "https://www.foxesscloud.com/op/v0/device/report/query")!
    static var getOpenBatterySOC = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/soc/get")!
    static var getOpenDeviceList = URL(string: "https://www.foxesscloud.com/op/v0/device/list")!
    static var getOpenDeviceDetail = URL(string: "https://www.foxesscloud.com/op/v0/device/detail")!
    static var setOpenBatterySOC = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/soc/set")!
    static var getOpenBatteryChargeTimes = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/forceChargeTime/get")!
    static var setOpenBatteryChargeTimes = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/forceChargeTime/set")!
    static var getOpenModuleList = URL(string: "https://www.foxesscloud.com/op/v0/module/list")!
    static var getOpenPlantList = URL(string: "https://www.foxesscloud.com/op/v0/plant/list")!
    static var getOpenPlantDetail = URL(string: "https://www.foxesscloud.com/op/v0/plant/detail")!
}

extension FoxAPIService {
    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        var request = URLRequest(url: URL.getOpenRealData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(OpenQueryRequest(deviceSN: deviceSN, variables: variables))

        do {
            let result: ([OpenQueryResponse], Data) = try await fetch(request)
            if let group = result.0.first(where: { $0.deviceSN == deviceSN }) {
                return group
            } else {
                throw NetworkError.missingData
            }
        } catch {
            print(error)
            throw error
        }
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        var request = URLRequest(url: URL.getOpenHistoryData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(
            OpenHistoryRequest(
                sn: deviceSN,
                variables: variables,
                begin: start.timeIntervalSince1970 * 1000,
                end: end.timeIntervalSince1970 * 1000
            )
        )

        do {
            let result: ([OpenHistoryResponse], Data) = try await fetch(request)
            if let group = result.0.first(where: { $0.deviceSN == deviceSN }) {
                return group
            } else {
                throw NetworkError.missingData
            }
        } catch {
            print(error)
            throw error
        }
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        let request = URLRequest(url: URL.getOpenVariables)
        let result: (OpenApiVariableArray, Data) = try await fetch(request)
        return result.0.array
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        var request = URLRequest(url: URL.getOpenReportData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(OpenReportRequest(deviceSN: deviceSN, variables: variables, queryDate: queryDate, dimension: reportType))

        let result: ([OpenReportResponse], Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.getOpenBatterySOC)

        let result: (BatterySOCResponse, Data) = try await fetch(request)
        storeBatterySettingsResponse(NetworkOperation(description: "fetchBatterySettings", value: result.0, raw: result.1))
        return result.0
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        var request = URLRequest(url: URL.setOpenBatterySOC)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(SetBatterySOCRequest(minSocOnGrid: minSOCOnGrid, minSoc: minSOC, sn: deviceSN))

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.getOpenBatteryChargeTimes)

        let result: (BatteryTimesResponse, Data) = try await fetch(request)
        storeBatteryTimesResponse(NetworkOperation(description: "batteryTimesResponse", value: result.0, raw: result.1))

        return [
            ChargeTime(enable: result.0.enable1, startTime: result.0.startTime1, endTime: result.0.endTime1),
            ChargeTime(enable: result.0.enable2, startTime: result.0.startTime2, endTime: result.0.endTime2)
        ]
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        guard times.count >= 2 else { return }

        var request = URLRequest(url: URL.setOpenBatteryChargeTimes)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(
            SetBatteryTimesRequest(sn: deviceSN,
                                   enable1: times[0].enable,
                                   startTime1: times[0].startTime,
                                   endTime1: times[0].endTime,
                                   enable2: times[1].enable,
                                   startTime2: times[1].startTime,
                                   endTime2: times[1].endTime)
        )

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        var request = URLRequest(url: URL.getOpenDeviceList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DeviceListRequest())

        let deviceListResult: (PagedDeviceListResponse, _) = try await fetch(request)

        storeDeviceListResponse(NetworkOperation(description: "fetchDeviceList", value: deviceListResult.0.data, raw: deviceListResult.1))
        return deviceListResult.0.data
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.getOpenDeviceDetail)

        let result: (DeviceDetailResponse, _) = try await fetch(request)
        return result.0
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        var request = URLRequest(url: URL.getOpenModuleList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DataLoggerListRequest())

        let result: ([DataLoggerResponse], Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        var request = URLRequest(url: URL.getOpenPlantList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(PowerStationListRequest())

        let result: (PagedPowerStationListResponse, Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        let request = append(queryItems: [URLQueryItem(name: "id", value: stationID)], to: URL.getOpenPlantDetail)

        let result: (PowerStationDetailResponse, _) = try await fetch(request)
        return result.0
    }

    private func storeBatterySettingsResponse(_ operation: NetworkOperation<BatterySOCResponse>) {
        Task { @MainActor in
            store.batterySettingsResponse = operation
        }
    }

    private func storeBatteryTimesResponse(_ operation: NetworkOperation<BatteryTimesResponse>) {
        Task { @MainActor in
            store.batteryTimesResponse = operation
        }
    }

    private func storeDeviceListResponse(_ operation: NetworkOperation<[DeviceSummaryResponse]>) {
        Task { @MainActor in
            store.deviceListResponse = operation
        }
    }
}
