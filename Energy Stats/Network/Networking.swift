//
//  Networking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

extension URL {
    static var auth = URL(string: "https://www.foxesscloud.com/c/v0/user/login")!
    static var report = URL(string: "https://www.foxesscloud.com/c/v0/device/history/report")!
    static var raw = URL(string: "https://www.foxesscloud.com/c/v0/device/history/raw")!
    static var battery = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/info")!
    static var deviceList = URL(string: "https://www.foxesscloud.com/c/v0/device/list")!
    static var soc = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/soc/get")!
    static var addressBook = URL(string: "https://www.foxesscloud.com/c/v0/device/addressbook")!  // ?deviceID = XXX
}

protocol Networking {
    func ensureHasToken() async
    func verifyCredentials(username: String, hashedPassword: String) async throws
    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse]
    func fetchBattery(deviceID: String) async throws -> BatteryResponse
    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse
    func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse]
    func fetchDeviceList() async throws -> PagedDeviceListResponse
    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse
}

class Network: Networking {
    private var token: String? {
        get { credentials.getToken() }
        set {
            do { try credentials.store(token: newValue) }
            catch { print("AWP", "Could not store token") }
        }
    }

    private let credentials: KeychainStore
    private let config: Config

    init(credentials: KeychainStore, config: Config) {
        self.credentials = credentials
        self.config = config
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        _ = try await fetchLoginToken(username: username, hashedPassword: hashedPassword)
    }

    func ensureHasToken() async {
        do {
            if token == nil {
                token = try await fetchLoginToken()
            }
        } catch {
            // TODO:
        }
    }

    func fetchLoginToken(username: String? = nil, hashedPassword: String? = nil) async throws -> String {
        guard let hashedPassword = hashedPassword ?? credentials.getHashedPassword(),
              let username = username ?? credentials.getUsername() else { throw NetworkError.badCredentials }

        var request = URLRequest(url: URL.auth)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(AuthRequest(user: username, password: hashedPassword))

        let response: AuthResponse = try await fetch(request, retry: false)

        return response.token
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        var request = URLRequest(url: URL.report)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(ReportRequest(deviceID: deviceID, variables: variables, queryDate: queryDate))

        return try await fetch(request)
    }

    func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        var request = URLRequest(url: URL.battery)
        request.url?.append(queryItems: [Foundation.URLQueryItem(name: "id", value: deviceID)])

        return try await fetch(request)
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        var request = URLRequest(url: URL.soc)
        request.url?.append(queryItems: [Foundation.URLQueryItem(name: "sn", value: deviceSN)])

        return try await fetch(request)
    }

    func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
        var request = URLRequest(url: URL.raw)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(RawRequest(deviceID: deviceID, variables: variables))

        return try await fetch(request)
    }

    func fetchDeviceList() async throws -> PagedDeviceListResponse {
        var request = URLRequest(url: URL.deviceList)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(DeviceListRequest())

        return try await fetch(request)
    }

    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        var request = URLRequest(url: URL.addressBook)
        request.url?.append(queryItems: [URLQueryItem(name: "deviceID", value: deviceID)])

        return try await fetch(request)
    }
}

private extension Network {
    func fetch<T: Decodable>(_ request: URLRequest, retry: Bool = true) async throws -> T {
        var request = request
        addHeaders(to: &request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.unknown
            }

            guard 200 ... 300 ~= statusCode else { throw NetworkError.invalidResponse(request.url, statusCode) }

            let networkResponse: NetworkResponse<T> = try JSONDecoder().decode(NetworkResponse<T>.self, from: data)

            if [41808, 41809, 41810].contains(networkResponse.errno) { // 41808 41810 ?
                throw NetworkError.invalidToken
            } else if networkResponse.errno == 41807 {
                throw NetworkError.badCredentials
            } else if networkResponse.errno == 40401 {  
                throw NetworkError.tryLater
            }

            if let result = networkResponse.result {
                return result
            }

            throw NetworkError.invalidResponse(request.url, statusCode)
        } catch let error as NetworkError {
            switch error {
            case .invalidToken where retry:
                token = nil
                token = try await fetchLoginToken()
                return try await fetch(request, retry: false)
            default:
                throw error
            }
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain, error.code == URLError.notConnectedToInternet.rawValue {
                throw NetworkError.offline
            } else {
                throw error
            }
        }
    }

    func addHeaders(to request: inout URLRequest) {
        request.setValue(token, forHTTPHeaderField: "token")
        request.setValue(UserAgent.random(), forHTTPHeaderField: "User-Agent")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("https://www.foxesscloud.com/bus/device/inverterDetail?id=xyz&flowType=1&status=1&hasPV=true&hasBattery=true", forHTTPHeaderField: "Referrer")
        request.setValue("en-US;q=0.9,en;q=0.8,de;q=0.7,nl;q=0.6", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

enum UserAgent {
    static func random() -> String {
        let values = [
            "Mozilla/5.0 (Linux; Android 12; SM-S906N Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.119 Mobile Safari/537.36",
            "Mozilla/5.0 (Linux; Android 10; SM-G996U Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Mobile Safari/537.36",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1",
            "Mozilla/5.0 (Linux; Android 7.0; SM-T827R4 Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.116 Safari/537.36",
            "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36",
            "AppleTV11,1/11.1",
            "Mozilla/5.0 (iPhone14,3; U; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/19A346 Safari/602.1",
            "Mozilla/5.0 (iPhone13,2; U; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/15E148 Safari/602.1"
        ]

        return values.randomElement()!
    }
}

extension LocalizedError where Self: CustomStringConvertible {
    var errorDescription: String? {
        return description
    }
}
