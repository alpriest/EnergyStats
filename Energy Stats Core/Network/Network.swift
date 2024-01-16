//
//  Network.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 09/12/2023.
//

import Foundation

public class Network: FoxESSNetworking {
    private var token: String? {
        credentials.getToken()
    }

    private let credentials: KeychainStoring
    let store: InMemoryLoggingNetworkStore
    private var errorMessages: [String: String] = [:]

    public init(credentials: KeychainStoring, store: InMemoryLoggingNetworkStore) {
        self.credentials = credentials
        self.store = store
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        var request = URLRequest(url: URL.report)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(ReportRequest(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType))

        let result: ([ReportResponse], Data) = try await fetch(request)
        store.reportResponse = NetworkOperation(description: "fetchReport", value: result.0, raw: result.1)
        return result.0
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        let request = append(queryItems: [URLQueryItem(name: "id", value: deviceID)], to: URL.battery)

        let result: (BatteryResponse, Data) = try await fetch(request)
        store.batteryResponse = NetworkOperation(description: "fetchBattery", value: result.0, raw: result.1)
        return result.0
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        var request = URLRequest(url: URL.raw)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(RawRequest(deviceID: deviceID, variables: variables, queryDate: queryDate))

        let result: ([RawResponse], Data) = try await fetch(request)
        store.rawResponse = NetworkOperation(description: "fetchRaw", value: result.0, raw: result.1)
        return result.0
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        var request = URLRequest(url: URL.deviceList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DeviceListRequest())

        let deviceListResult: (PagedDeviceListResponse, _) = try await fetch(request)
        let devices = try await deviceListResult.0.data.asyncMap {
            try await openapi_fetchDevice(deviceSN: $0.deviceSN)
        }

        store.deviceListResponse = NetworkOperation(description: "fetchDeviceList", value: devices, raw: deviceListResult.1)
        return devices
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        let request = append(queryItems: [URLQueryItem(name: "sn", value: deviceSN)], to: URL.deviceDetail)

        let result: (DeviceDetailResponse, _) = try await fetch(request)
        return result.0
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        let request = append(queryItems: [URLQueryItem(name: "deviceID", value: deviceID)], to: URL.addressBook)

        let result: (AddressBookResponse, Data) = try await fetch(request)
        store.addressBookResponse = NetworkOperation(description: "fetchAddressBookResponse", value: result.0, raw: result.1)
        return result.0
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        let request = append(queryItems: [URLQueryItem(name: "deviceID", value: deviceID)], to: URL.variables)

        let result: (VariablesResponse, Data) = try await fetch(request)
        store.variables = NetworkOperation(description: "fetchVariables", value: result.0, raw: result.1)
        return result.0.variables
    }

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        let request = append(queryItems: [
            URLQueryItem(name: "id", value: deviceID),
            URLQueryItem(name: "hasVersionHead", value: "1"),
            URLQueryItem(name: "key", value: "operation_mode__work_mode"),
        ], to: URL.deviceSettings)

        let result: (DeviceSettingsGetResponse, Data) = try await fetch(request)
//        store.inverterWorkModeResponse = NetworkOperation(description: "inverterWorkModeResponse", value: result.0, raw: result.1)
        return result.0
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {
        var request = URLRequest(url: URL.deviceSettingsSet)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DeviceSettingsSetRequest(id: deviceID, key: .operationModeWorkMode, values: InverterValues(operationModeWorkMode: workMode)))

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        var request = URLRequest(url: URL.moduleList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DataLoggerListRequest())

        let result: (PagedDataLoggerListResponse, Data) = try await fetch(request)
//        store.inverterWorkModeResponse = NetworkOperation(description: "inverterWorkModeResponse", value: result.0, raw: result.1)
        return result.0
    }

    public func fetchErrorMessages() async {
        let request = URLRequest(url: URL.errorMessages)

        do {
            let result: (ErrorMessagesResponse, Data) = try await fetch(request)
            errorMessages = result.0.messages[languageCode] ?? [:]
        } catch {
            // Ignore
        }
    }
}

extension Network {
    func append(queryItems: [URLQueryItem], to url: URL) -> URLRequest {
        let request: URLRequest

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        request = URLRequest(url: components!.url!)

        return request
    }

    func fetch<T: Decodable>(_ request: URLRequest, retry: Bool = true) async throws -> (T, Data) {
        var request = request
        addHeaders(to: &request)
        store.latestRequest = request

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.unknown("Invalid response type")
            }

            store.latestData = data
            store.latestResponse = response

            if statusCode == 406 {
                throw NetworkError.requestRequiresSignature
            }

            guard 200 ... 300 ~= statusCode else { throw NetworkError.invalidResponse(request.url, statusCode) }

            let networkResponse: NetworkResponse<T> = try JSONDecoder().decode(NetworkResponse<T>.self, from: data)

            if networkResponse.errno > 0 {
                if [41808, 41809, 41810].contains(networkResponse.errno) {
                    throw NetworkError.invalidToken
                } else if networkResponse.errno == 41807 {
                    throw NetworkError.badCredentials
                } else if networkResponse.errno == 40401 {
                    throw NetworkError.tryLater
                } else if networkResponse.errno == 30000 {
                    throw NetworkError.maintenanceMode
                } else {
                    throw NetworkError.foxServerError(networkResponse.errno, errorMessage(for: networkResponse.errno))
                }
            }

            if let result = networkResponse.result {
                return (result, data)
            }

            throw NetworkError.invalidResponse(request.url, statusCode)
        } catch let error as NSError {
            print(error)
            if error.domain == NSURLErrorDomain, error.code == URLError.notConnectedToInternet.rawValue {
                throw NetworkError.offline
            } else {
                throw error
            }
        }
    }

    private func errorMessage(for errno: Int) -> String {
        errorMessages[String(errno)] ?? "Unknown"
    }

    func addHeaders(to request: inout URLRequest) {
        if let token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("en-US;q=0.9,en;q=0.8,de;q=0.7,nl;q=0.6", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(languageCode, forHTTPHeaderField: "lang")
        request.setValue(timezone, forHTTPHeaderField: "timezone")

        let timestamp = Int(round(Date().timeIntervalSince1970 * 1000))

        request.setValue(String(describing: timestamp), forHTTPHeaderField: "timestamp")
        request.setValue(openAPISignature(for: request), forHTTPHeaderField: "signature")
    }

    private var languageCode: String {
        guard let languageCode = Locale.preferredLanguages.first else { return "en" }
        return languageCode.split(separator: "-").first.map(String.init) ?? "en"
    }

    private var timezone: String {
        TimeZone.current.identifier
    }

    private func openAPISignature(for request: URLRequest) -> String {
        let parts = [
            request.url?.path ?? "",
            request.header(for: "token"),
            request.header(for: "timestamp"),
        ]

        return parts.joined(separator: "\\r\\n").md5()!
    }
}

extension LocalizedError where Self: CustomStringConvertible {
    var errorDescription: String? {
        return description
    }
}

extension URLRequest {
    func header(for field: String) -> String {
        value(forHTTPHeaderField: field) ?? ""
    }
}
