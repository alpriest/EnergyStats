//
//  Bool+Int.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/01/2024.
//

import Foundation

public extension Bool {
    var intValue: Int {
        self ? 1 : 0
    }
}

public extension Int {
    var boolValue: Bool {
        self == 1
    }
}
