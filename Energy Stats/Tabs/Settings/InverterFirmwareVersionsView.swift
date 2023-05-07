//
//  InverterFirmwareVersionsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterFirmwareVersionsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel

    var body: some View {
        Section(
            content: {
                if let version = viewModel.firmwareVersions {
                    HStack {
                        Text("Manager: ") +
                            Text(version.manager)
                        Text("Slave: ") +
                            Text(version.slave)
                        Text("Master: ") +
                            Text(version.master)
                    }.contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = "Manager: \(version.manager) Slave: \(version.slave) Master: \(version.master)"
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            },
            header: { Text("Firmware Versions") },
            footer: {
                VStack(alignment: .leading) {
                    Text("Find out more about firmware versions from the ") +
                        Text("foxesscommunity.com")
                        .foregroundColor(Color.blue) +
                        Text(" website")
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: "https://foxesscommunity.com/viewforum.php?f=29")!)
                }
            }
        )
    }
}

#if DEBUG
struct InverterFirmwareVersionsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            InverterFirmwareVersionsView(viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: PreviewConfigManager()
            ))
        }
    }
}
#endif
