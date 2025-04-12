//
//  VersionChecker.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/03/2024.
//

import Combine
import Foundation

// Added in version 2.10
public class VersionChecker: ObservableObject {
    @Published public var latestVersion: String = ""
    @Published public var upgradeAvailable: Bool = false
    public let appStoreUrl = URL(string: "https://itunes.apple.com/app/id1644492526?mt=8")!

    private let urlSession: URLSessionProtocol

    public init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }

    public func load() {
        guard let updateURL = URL(string: "https://raw.githubusercontent.com/alpriest/EnergyStats/main/Energy%20Stats/version.json") else { return }

        Task {
            do {
                let request = URLRequest(url: updateURL)
                let (data, _) = try await urlSession.data(for: request, delegate: nil)

                try await MainActor.run {
                    latestVersion = try JSONDecoder().decode(VersionData.self, from: data).latest

                    if compareVersions(appVersion, latestVersion) == .orderedAscending {
                        upgradeAvailable = true
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    private var appVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }

    private struct VersionData: Decodable {
        let latest: String
    }

    func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let components1 = version1.split(separator: ".").map { Int($0) ?? 0 }
        let components2 = version2.split(separator: ".").map { Int($0) ?? 0 }

        for (component1, component2) in zip(components1, components2) {
            if component1 < component2 {
                return .orderedAscending
            } else if component1 > component2 {
                return .orderedDescending
            }
        }

        return components1.count < components2.count ? .orderedAscending : components1.count > components2.count ? .orderedDescending : .orderedSame
    }
}
