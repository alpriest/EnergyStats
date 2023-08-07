//
//  WorkMode.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 07/08/2023.
//

import Foundation
import SwiftUI

public enum WorkMode: CaseIterable, Describable {
    case selfUse
    case feedInFirst
    case backup
    case powerStation
    case peakShaving

    public var title: String {
        switch self {
        case .selfUse:
            return "Self Use"
        case .feedInFirst:
            return "Feed In First"
        case .backup:
            return "Backup"
        case .powerStation:
            return "Power Station"
        case .peakShaving:
            return "Peak Shaving"
        }
    }

    public var subtitle: some View {
        switch self {
        case .selfUse:
            return Text("self_use_mode")

        case .feedInFirst:
            return Text("feed_in_first_mode")

        case .backup:
            return Text("backup_mode")

        case .powerStation:
            return Text("powerstation_mode")

        case .peakShaving:
            return Text("peak_shaving_mode")
        }
    }
}
