//
//  SolcastSettings.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

public struct SolcastSettings: Codable {
    public let sites: [Site]

    public init(sites: [Site]) {
        self.sites = sites
    }

    public struct Site: Codable {
        public let resourceId: String
        public let apiKey: String
        public let name: String?

        public init(resourceId: String, apiKey: String, name: String?) {
            self.resourceId = resourceId
            self.apiKey = apiKey
            self.name = name
        }
    }
}
