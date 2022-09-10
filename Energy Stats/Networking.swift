//
//  Networking.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

extension URL {
    static var auth = URL(string: "https://www.foxesscloud.com/c/v0/user/login")!
    static var report = URL(string: "https://www.foxesscloud.com/c/v0/device/history/report")!
    static var raw = URL(string: "https://www.foxesscloud.com/c/v0/device/history/raw")!
    static var battery = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/info?id=03274209-486c-4ea3-9c28-159f25ee84cb")!
}

protocol Networking {
    func fetchReport() async throws -> ReportResponse
    func fetchBattery() async throws -> BatteryResponse
    func fetchRaw(variables: [String]) async throws -> RawResponse
}

class Network: Networking, ObservableObject {
    enum NetworkError: Error {
        case badCredentials
        case unknown
    }

    var token: String?
    let credentials: Credentials

    init(credentials: Credentials) {
        self.credentials = credentials
    }

    func fetchToken() async throws -> String {
        guard let hashedPassword = credentials.hashedPassword, let username = credentials.username else { throw NetworkError.badCredentials }

        var request = URLRequest(url: URL.auth)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(AuthRequest(user: username, password: hashedPassword))
        addHeaders(to: &request)

        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)

        if result.hasFailed {
            throw NetworkError.badCredentials
        }

        if let result = result.result {
            return result.token
        } else {
            throw NetworkError.unknown
        }
    }

    func fetchReport() async throws -> ReportResponse {
        if token == nil {
            token = try await fetchToken()
        }

        var request = URLRequest(url: URL.report)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(ReportRequest(deviceID: Config.deviceID))
        addHeaders(to: &request)

        return try await fetch(request)
    }

    func fetchBattery() async throws -> BatteryResponse {
        if token == nil {
            token = try await fetchToken()
        }

        var request = URLRequest(url: URL.battery)
        addHeaders(to: &request)

        return try await fetch(request)
    }

    func fetchRaw(variables: [String]) async throws -> RawResponse {
        if token == nil {
            token = try await fetchToken()
        }

        var request = URLRequest(url: URL.raw)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(RawRequest(deviceID: Config.deviceID, variables: variables))
        addHeaders(to: &request)

        return try await fetch(request)
    }

    private func fetch<T: Decodable>(_ request: URLRequest, retry: Bool = false) async throws -> T {
        if token == nil {
            token = try await fetchToken()
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if !retry {
                token = try await fetchToken()
                return try await fetch(request, retry: true)
            } else {
                throw error
            }
        }
    }

    private func addHeaders(to request: inout URLRequest) {
        request.setValue(token, forHTTPHeaderField: "token")
        request.setValue(UserAgent.random(), forHTTPHeaderField: "User-Agent")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("https://www.foxesscloud.com/bus/device/inverterDetail?id=xyz&flowType=1&status=1&hasPV=true&hasBattery=true", forHTTPHeaderField: "Referrer")
        request.setValue("en-US;q=0.9,en;q=0.8,de;q=0.7,nl;q=0.6", forHTTPHeaderField: "Accept-Language")
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
