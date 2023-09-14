//
//  ParameterGroup.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 14/09/2023.
//

import Foundation

public struct ParameterGroup: Codable {
    public let title: String
    public let parameterNames: [String]

    public init(title: String, parameterNames: [String]) {
        self.title = title
        self.parameterNames = parameterNames
    }
}
