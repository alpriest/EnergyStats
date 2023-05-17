//
//  Array+Safe.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation

public extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices ~= index else { return nil }
        return self[index]
    }
}
