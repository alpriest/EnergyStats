//
//  SolcastSettings.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

public struct SolcastSettings: Codable, Equatable {
    public let apiKey: String?
    public let sites: [SolcastSite]

    public init(apiKey: String?, sites: [SolcastSite]) {
        self.apiKey = apiKey
        self.sites = sites
    }
}

public struct SolcastSite: Codable, Equatable {
    public let name: String
    public let resourceId: String
    public let lng: Double
    public let lat: Double
    public let azimuth: Int
    public let tilt: Double
    public let lossFactor: Double?
    public let acCapacity: Double
    public let dcCapacity: Double?
    public let installDate: Date?

    public init(name: String, resourceId: String, lng: Double, lat: Double, azimuth: Int, tilt: Double, lossFactor: Double?, acCapacity: Double, dcCapacity: Double?, installDate: Date?) {
        self.name = name
        self.resourceId = resourceId
        self.lng = lng
        self.lat = lat
        self.azimuth = azimuth
        self.tilt = tilt
        self.lossFactor = lossFactor
        self.acCapacity = acCapacity
        self.dcCapacity = dcCapacity
        self.installDate = installDate
    }

    public init(site: SolcastSiteResponse) {
        self.init(name: site.name,
                  resourceId: site.resourceId,
                  lng: site.longitude,
                  lat: site.latitude,
                  azimuth: site.azimuth,
                  tilt: site.tilt,
                  lossFactor: site.lossFactor,
                  acCapacity: site.capacity,
                  dcCapacity: site.dcCapacity,
                  installDate: site.installDate)
    }

    public static func == (lhs: SolcastSite, rhs: SolcastSite) -> Bool {
        // Compare non-floating properties with strict equality
        guard lhs.name == rhs.name,
              lhs.resourceId == rhs.resourceId,
              lhs.azimuth == rhs.azimuth,
              lhs.installDate == rhs.installDate else { return false }

        // Compare Double properties using approxEquals
        guard lhs.lng.approxEqual(rhs.lng),
              lhs.lat.approxEqual(rhs.lat),
              lhs.tilt.approxEqual(rhs.tilt),
              lhs.acCapacity.approxEqual(rhs.acCapacity) else { return false }

        return lhs.lossFactor.approxEqual(other: rhs.lossFactor) &&
            lhs.dcCapacity.approxEqual(other: rhs.dcCapacity)
    }
}
