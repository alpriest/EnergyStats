//
//  BatteryChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

enum BatteryChargeTab {
    case forceCharge
    case soc
}

struct BatteryChargeSettingsView: View {
    @State private var soc: String
    @State private var socOnGrid: String
    @State private var timePeriod1: ChargeTimePeriod
    @State private var timePeriod2: ChargeTimePeriod
    @State private var tabView: BatteryChargeTab = .forceCharge

    init(soc: Int, socOnGrid: Int, timePeriod1: ChargeTimePeriod, timePeriod2: ChargeTimePeriod) {
        self._timePeriod1 = State(initialValue: timePeriod1)
        self._timePeriod2 = State(initialValue: timePeriod2)
        self._soc = State(initialValue: String(describing: soc))
        self._socOnGrid = State(initialValue: String(describing: socOnGrid))
    }

    var body: some View {
        Form {
            Picker(selection: $tabView) {
                Text("Force Charge")
                    .tag(BatteryChargeTab.forceCharge)
                Text("SOC")
                    .tag(BatteryChargeTab.soc)
            } label: {
                Text("Group")
            }
            .pickerStyle(.segmented)

            Group {
                switch tabView {
                case .forceCharge:
                    BatteryForceChargeSettingsView(timePeriod1: $timePeriod1, timePeriod2: $timePeriod2)
                case .soc:
                    BatterySOCSettingsView(soc: $soc, socOnGrid: $socOnGrid)
                }
            }
        }
    }
}

struct BatteryChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryChargeSettingsView(soc: 10,
                                  socOnGrid: 20,
                                  timePeriod1: .init(start: nil, end: nil, enabled: false),
                                  timePeriod2: .init(start: nil, end: nil, enabled: false))
    }
}

struct ChargeTimePeriod: Equatable {
    var start: Date
    var end: Date
    var enabled: Bool

    init(start: Date? = nil, end: Date? = nil, enabled: Bool) {
        self.start = start ?? .zero()
        self.end = end ?? .zero()
        self.enabled = enabled
    }

    var description: String? {
        if enabled {
            return "Your battery will be charged from \(start.militaryTime()) to \(end.militaryTime())"
        } else {
            return nil
        }
    }

    var validate: String? {
        if start > end {
            return "Start time must be before the end time"
        }

        return nil
    }

    var valid: Bool {
        validate == nil
    }
}

extension Date {
    static func zero() -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: 0, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: 0, of: result) ?? .now
    }
}
