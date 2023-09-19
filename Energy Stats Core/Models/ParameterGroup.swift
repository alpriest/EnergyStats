//
//  ParameterGroup.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 14/09/2023.
//

import Foundation

public struct ParameterGroup: Codable, Hashable, Identifiable {
    public let id: UUID
    public let title: String
    public let parameterNames: [String]

    public init(id: UUID, title: String, parameterNames: [String]) {
        self.id = id
        self.title = title
        self.parameterNames = parameterNames
    }
}
