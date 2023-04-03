//
//  GraphVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/11/2022.
//

import Foundation
import Energy_Stats_Core

struct GraphVariable: Identifiable, Equatable, Hashable {
    let type: RawVariable
    var enabled = true
    var id: String { type.title(as: .snapshot) }

    init(_ type: RawVariable, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }
}

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: RawVariable

    var id: String { "\(date.iso8601())_\(variable.rawValue)" }

    init(date: Date, queryDate: QueryDate, value: Double, variable: RawVariable) {
        self.date = date
        self.value = value
        self.variable = variable
    }
}
