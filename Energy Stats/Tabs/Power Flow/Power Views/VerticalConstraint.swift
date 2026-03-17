//
//  VerticallyConstrained.swift
//  Energy Stats
//
//  Created by Alistair Priest on 17/03/2026.
//

import Energy_Stats_Core
import SwiftUI

enum VerticalConstraint {
    static func isConstrained(
        dynamicTypeSize: DynamicTypeSize,
        appSettings: AppSettings
    ) -> Bool {
        let verticallyConstrainingItemCount = [
            appSettings.showBatteryMaxChargeCurrent,
            appSettings.showInverterTemperature,
            appSettings.showInverterStationName,
            appSettings.showInverterTypeName,
            dynamicTypeSize > DynamicTypeSize.large
        ].count { $0 == true }

        return UIWindowScene.isVerticallyConstrained || verticallyConstrainingItemCount > 3
    }
}
