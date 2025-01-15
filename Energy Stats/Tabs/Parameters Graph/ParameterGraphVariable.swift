//
//  GraphVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/11/2022.
//

import Energy_Stats_Core
import Foundation

struct ParameterGraphVariable: Identifiable, Equatable, Hashable {
    let type: Variable
    var enabled: Bool
    var isSelected: Bool
    var id: String { type.title(as: .snapshot) }

    init(_ type: Variable, isSelected: Bool = false, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
        self.isSelected = isSelected
    }

    init?(_ type: Variable?, isSelected: Bool = false, enabled: Bool = true) {
        guard let type else { return nil }

        self.init(type, isSelected: isSelected, enabled: enabled)
    }

    mutating func setSelected(_ selected: Bool) {
        isSelected = selected
        enabled = true
    }
}

struct ParameterGraphValue: Identifiable, Hashable {
    let date: Date
    let value: Double
    let type: Variable

    var id: String { "\(date.iso8601())_\(type.variable)" }

    init(date: Date, value: Double, variable: Variable) {
        self.date = date

        // Rescale values that match 10Wh to kWh
        switch variable.unit {
        case "10Wh":
            self.value = value / 100.0
            self.type = variable.copy(unit: "kWh")
        default:
            self.value = value
            self.type = variable
        }
    }

    func formatted() -> String {
        switch type.unit {
        case "kW":
            return value.kW(2)
        default:
            return "\(value) \(type.unit)"
        }
    }
}

struct ParameterGraphBounds {
    let type: Variable
    let min: Double?
    let max: Double?
    let now: Double?
}
