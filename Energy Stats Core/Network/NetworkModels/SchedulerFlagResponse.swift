//
//  SchedulerFlagResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/11/2023.
//

import Foundation

public struct SchedulerFlagResponse: Decodable {
    public let enable: Bool
    public let support: Bool
}
