//
//  SchedulePhaseEditViewData.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/11/2025.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseEditViewData: Copiable {
    var id: String
    var startTime: Date
    var endTime: Date
    var workMode: WorkMode
    var minSOC: String
    var fdSOC: String
    var fdPower: String
    var maxSOC: String
    var showMaxSOC: Bool
    var modes: [String]

    func create(copying previous: SchedulePhaseEditViewData) -> SchedulePhaseEditViewData {
        SchedulePhaseEditViewData(
            id: previous.id,
            startTime: previous.startTime,
            endTime: previous.endTime,
            workMode: previous.workMode,
            minSOC: previous.minSOC,
            fdSOC: previous.fdSOC,
            fdPower: previous.fdPower,
            maxSOC: previous.maxSOC,
            showMaxSOC: previous.showMaxSOC,
            modes: previous.modes
        )
    }
}
