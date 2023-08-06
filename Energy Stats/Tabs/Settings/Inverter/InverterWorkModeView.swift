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
        default:
            return Text("")
        }
    }
}

struct InverterWorkModeView: View {
    var body: some View {
        SingleSelectView(SingleSelectableListViewModel([WorkModes.selfUse],
                                                       allItems: WorkModes.allCases,
                                                       onApply: { _ in }))
        {
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
        }
        .navigationTitle("Configure Work Mode")
        .navigationBarTitleDisplayMode(.inline)
//            } header: {
//                Text("All")
//            } footer: {
//                Link(destination: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Fox-ESS-Cloud#search-parameters")!) {
//                    HStack {
//                        Text("Find out more about these variables")
//                        Image(systemName: "rectangle.portrait.and.arrow.right")
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .font(.caption)
//                }
//            }
//        }
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView()
        }
    }
}
