//
//  StatsGraphVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/09/2026.
//

import Energy_Stats_Core
import SwiftUI

struct StatsGraphVariable: Identifiable, Equatable, Hashable {
    let type: ReportVariable
    var enabled: Bool
    var id: String { type.titleTotal }

    init(_ type: ReportVariable, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }

    init?(_ type: ReportVariable?, enabled: Bool = true) {
        guard let type else { return nil }

        self.init(type, enabled: enabled)
    }
}
