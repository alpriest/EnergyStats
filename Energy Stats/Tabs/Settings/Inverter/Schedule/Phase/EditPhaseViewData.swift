//
//  EditPhaseViewData.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/11/2025.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct EditPhaseViewData: Copiable {
    var id: String
    var startTime: Date
    var endTime: Date
    var workMode: WorkMode
    var modes: [String]
    var fields: [SchedulePhaseFieldDefinition]
    var showAdvancedFields: Bool

    func create(copying previous: EditPhaseViewData) -> EditPhaseViewData {
        EditPhaseViewData(
            id: previous.id,
            startTime: previous.startTime,
            endTime: previous.endTime,
            workMode: previous.workMode,
            modes: previous.modes,
            fields: previous.fields,
            showAdvancedFields: previous.showAdvancedFields
        )
    }
}
