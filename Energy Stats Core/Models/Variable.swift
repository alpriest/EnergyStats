//
//  Variable.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 27/12/2023.
//

import Foundation

public struct Variable {
    public let name: String
    public let variable: String
    public let unit: String

    public init(name: String, variable: String, unit: String) {
        self.name = name
        self.variable = variable
        self.unit = unit
    }
}
