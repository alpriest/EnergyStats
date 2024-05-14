//
//  Network.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 09/12/2023.
//

import Foundation

class FoxAPIService: FoxAPIServicing {
    private var token: String? {
        credentials.getToken()
    }

    private let credentials: KeychainStoring
    var store: InMemoryLoggingNetworkStore
    private var errorMessages: [String: String] = [:]

    public init(credentials: KeychainStoring, store: InMemoryLoggingNetworkStore) {
        self.credentials = credentials
        self.store = store
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

extension FoxAPIService {
    func append(queryItems: [URLQueryItem], to url: URL) -> URLRequest {
        let request: URLRequest

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        request = URLRequest(url: components!.url!)

        return request
    }

    func store<T: Decodable>(_ operation: NetworkOperation<T>, path: WritableKeyPath<InMemoryLoggingNetworkStore, NetworkOperation<T>?>) {
        Task { @MainActor in
            store[keyPath: path] = operation
        }
    }

    func fetch<T: Decodable>(_ request: URLRequest, retry: Bool = true) async throws -> (T, Data) {
        var request = request
        request.timeoutInterval = 30
        addHeaders(to: &request)
        let requestResponseData = RequestResponseData(request: request, response: nil, responseData: nil)
        store(
            NetworkOperation(description: "latestRequestResponse", value: requestResponseData, raw: requestResponseData.combinedData),
            path: \.latestRequestResponseData
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = (response as? HTTPURLResponse) else {
                throw NetworkError.unknown("Invalid response type")
            }

            let statusCode = httpResponse.statusCode

            let requestResponseData = RequestResponseData(request: request, response: httpResponse, responseData: data)
            store(
                NetworkOperation(description: "latestRequestResponse", value: requestResponseData, raw: requestResponseData.combinedData),
                path: \.latestRequestResponseData
            )

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
            } else if error.domain == NSURLErrorDomain, error.code == URLError.timedOut.rawValue {
                throw NetworkError.timedOut
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

        let timestamp = Int64(round(Date().timeIntervalSince1970 * 1000))

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

public class RequestResponseData: Codable {
    public let request: String
    public let requestHeaders: [String]
    public let responseHeaders: [String]
    public let responseData: Data?

    var combinedData: Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }

    init(request: URLRequest, response: URLResponse?, responseData: Data?) {
        self.request = request.debugDescription
        self.requestHeaders = request.allHTTPHeaderFields?.map { "\($0.key) = \($0.value)" } ?? []
        self.responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields.map { "\($0.key) = \($0.value)" } ?? []
        self.responseData = responseData
    }
}
