//
//  SolcastSettings.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

public struct SolcastSettings: Codable {
    public let apiKey: String?
    public let sites: [SolcastSite]

    public init(apiKey: String?, sites: [SolcastSite]) {
        self.apiKey = apiKey
        self.sites = sites
    }
}

public struct SolcastSite: Codable {
    public let name: String?
    public let resourceId: String
    public let capacity: Double
    public let lng: Double
    public let lat: Double
    public let azimuth: Int
    public let tilt: Int
    public let lossFactor: Double

    public init(name: String?, resourceId: String, capacity: Double, lng: Double, lat: Double, azimuth: Int, tilt: Int, lossFactor: Double) {
        self.name = name
        self.resourceId = resourceId
        self.capacity = capacity
        self.lng = lng
        self.lat = lat
        self.azimuth = azimuth
        self.tilt = tilt
        self.lossFactor = lossFactor
    }

    public init(site: SolcastSiteResponse) {
        self.init(name: site.name,
                  resourceId: site.resourceId,
                  capacity: site.capacity,
                  lng: site.longitude,
                  lat: site.latitude,
                  azimuth: site.azimuth,
                  tilt: site.tilt,
                  lossFactor: site.lossFactor)
    }
}
