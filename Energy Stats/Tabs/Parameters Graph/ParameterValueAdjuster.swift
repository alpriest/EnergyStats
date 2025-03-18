//
//  ParameterValueAdjuster.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2025.
//

import Energy_Stats_Core

struct ParameterValueAdjuster {
    private let config: ConfigManaging

    init(config: ConfigManaging) {
        self.config = config
    }

    func adjust(variables: [ParameterGraphValue]) -> [ParameterGraphValue] {
        variables.map { variable in
            if variable.type.name.lowercased() == "meterpower2" {
                variable.copy(invertValue: config.shouldInvertCT2)
            } else {
                variable
            }
        }
    }
}
