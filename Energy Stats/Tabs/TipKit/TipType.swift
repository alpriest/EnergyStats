//
//  TipKitManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/03/2025.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

extension TipType {
    private var separator: String { "." }

    var title: String {
        NSLocalizedString(["tip", storageKey, "title"].joined(separator: separator), bundle: .main, comment: "")
    }

    var body: String {
        NSLocalizedString(["tip", storageKey, "body"].joined(separator: separator), bundle: .main, comment: "")
    }

    var storageKey: String {
        switch self {
        case .placeholder:
            fatalError("Do not try to display this tip")
        case .statsPageEnergyBalanceChartAdded:
            "statsPageEnergyBalanceChartAdded"
        }
    }
}
