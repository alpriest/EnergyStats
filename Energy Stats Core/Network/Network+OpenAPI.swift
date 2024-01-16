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
    static var deviceList = URL(string: "https://www.foxesscloud.com/op/v0/device/list")!
    static var deviceDetail = URL(string: "https://www.foxesscloud.com/op/v0/device/detail")!
    static var setOpenBatterySOC = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/soc/set")!
    static var getOpenBatteryChargeTimes = URL(string: "https://www.foxesscloud.com/op/v0/device/battery/forceChargeTime/get")!
}

public extension Network {
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

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.getOpenBatterySOC)

        let result: (BatterySettingsResponse, Data) = try await fetch(request)
        store.batterySettingsResponse = NetworkOperation(description: "fetchBatterySettings", value: result.0, raw: result.1)
        return result.0
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        var request = URLRequest(url: URL.setOpenBatterySOC)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(SetBatterySOCRequest(minSOCOnGrid: minSOCOnGrid, minSoc: minSOC, sn: deviceSN))

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.getOpenBatteryChargeTimes)

        let result: (BatteryTimesResponse, Data) = try await fetch(request)
        store.batteryTimesResponse = NetworkOperation(description: "batteryTimesResponse", value: result.0, raw: result.1)
        return result.0
    }
}
