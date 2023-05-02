//
//  GraphVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/11/2022.
//

import Energy_Stats_Core
import Foundation

struct GraphVariable: Identifiable, Equatable, Hashable {
    let type: RawVariable
    var enabled: Bool
    var isSelected: Bool
    var id: String { type.title(as: .snapshot) }

    init(_ type: RawVariable, isSelected: Bool = false, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
        self.isSelected = isSelected
    }

    init?(_ type: RawVariable?, isSelected: Bool = false, enabled: Bool = true) {
        guard let type else { return nil }

        self.init(type, isSelected: isSelected, enabled: enabled)
    }

    mutating func setSelected(_ selected: Bool) {
        isSelected = selected
        enabled = true
    }
}

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: RawVariable

    var id: String { "\(date.iso8601())_\(variable.variable)" }

    init(date: Date, queryDate: QueryDate, value: Double, variable: RawVariable) {
        self.date = date
        self.value = value
        self.variable = variable
    }

    func formatted() -> String {
        switch variable.unit {
        case "kW":
            return value.kW(2)
        default:
            return "\(value) \(variable.unit)"
        }
    }
}
