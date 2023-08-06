//
//  InverterWorkModeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import SwiftUI

enum WorkModes: CaseIterable, Describable {
    case selfUse
    case feedInFirst
    case backup
    case powerStation
    case peakShaving

    var title: String {
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

    var subtitle: some View {
        switch self {
        case .selfUse:
            return Text("""
            In this mode, the inverter prioritises power allocation as follows:

            1. House Load
            2. Battery Charging
            3. Export
            """)

        case .feedInFirst:
            return Text("""
            In this mode, the inverter prioritises power allocation as follows:

            House Load
            Export
            Battery Charging
            """)

        case .backup:
            return Text("""
            In this mode, the inverter prioritises power allocation as follows:

            Battery Charging
            House Load
            Export
            """)
        case .powerStation:
            return Text("This mode has unknown behaviour")
        case .peakShaving:
            return Text("This mode has unknown behaviour")
        }
    }
}

struct InverterWorkModeView: View {
    var body: some View {
        SingleSelectView(SingleSelectableListViewModel([WorkModes.selfUse],
                                                       allItems: WorkModes.allCases,
                                                       onApply: { _ in }),
                         header: {
                             HStack {
                                 Image(systemName: "exclamationmark.triangle.fill")
                                     .font(.title)
                                     .foregroundColor(.red)

                                 Text("Only change these values if you know what you are doing")

                                 Image(systemName: "exclamationmark.triangle.fill")
                                     .font(.title)
                                     .foregroundColor(.red)
                             }
                             .padding(.vertical)
                         }, footer: {
                             Link(destination: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Inverter-Work-Modes")!) {
                                 HStack {
                                     Text("Find out more about work modes")
                                     Image(systemName: "rectangle.portrait.and.arrow.right")
                                 }
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .font(.caption)
                             }
                         })
                         .navigationTitle("Configure Work Mode")
                         .navigationBarTitleDisplayMode(.inline)
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView()
        }
    }
}
