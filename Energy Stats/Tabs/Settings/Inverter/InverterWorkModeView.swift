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
