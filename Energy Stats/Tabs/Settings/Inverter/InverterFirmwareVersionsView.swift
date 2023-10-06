//
//  InverterFirmwareVersionsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterFirmwareVersionsView: View {
    let viewModel: DeviceFirmwareVersion?

    var body: some View {
        Group {
            if let version = viewModel {
                Section {
                    ESLabeledText("Manager", value: version.manager)
                    ESLabeledText("Slave", value: version.slave)
                    ESLabeledText("Master", value: version.master)
                } header: {
                    Text("Firmware Versions")
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Find out more about firmware versions from the ") +
                            Text("foxesscommunity.com")
                            .foregroundColor(Color.blue) +
                            Text(" ") + Text("website")
                    }
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://foxesscommunity.com/viewforum.php?f=29")!)
                    }
                }
                .alertCopy(text(version))
            }
        }
    }

    func text(_ version: DeviceFirmwareVersion) -> String {
        "Manager: \(version.manager) Slave: \(version.slave) Master: \(version.master)"
    }
}

#if DEBUG
struct InverterFirmwareVersionsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            InverterFirmwareVersionsView(viewModel: DeviceFirmwareVersion.preview())
        }
    }
}
#endif
