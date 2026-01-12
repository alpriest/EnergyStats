//
//  SolarRangeDefinitions.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 10/09/2023.
//

import Foundation

public struct SolarRangeDefinitions: Codable, Equatable {
    public let breakPoint1: Double
    public let breakPoint2: Double
    public let breakPoint3: Double

    public static var `default`: SolarRangeDefinitions {
        SolarRangeDefinitions(
            breakPoint1: 1.0,
            breakPoint2: 2.0,
            breakPoint3: 3.0
        )
    }

    public init(breakPoint1: Double, breakPoint2: Double, breakPoint3: Double) {
        self.breakPoint1 = breakPoint1
        self.breakPoint2 = breakPoint2
        self.breakPoint3 = breakPoint3
    }

    public static func == (lhs: SolarRangeDefinitions, rhs: SolarRangeDefinitions) -> Bool {
        return lhs.breakPoint1.approxEqual(rhs.breakPoint1)
        && lhs.breakPoint2.approxEqual(rhs.breakPoint2)
        && lhs.breakPoint3.approxEqual(rhs.breakPoint3)
    }
}
