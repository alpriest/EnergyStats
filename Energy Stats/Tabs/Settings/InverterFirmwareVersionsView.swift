//
//  InverterFirmwareVersionsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import SwiftUI

class InverterFirmwareVersionsViewModel: ObservableObject {
    private let config: ConfigManaging
    @Published var version: DeviceFirmwareVersion?

    init(config: ConfigManaging) {
        self.config = config
    }

    func load() {
        Task {
            do {
                let result = try await config.fetchFirmwareVersions()

                await MainActor.run {
                    self.version = result
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct InverterFirmwareVersionsView: View {
    @ObservedObject var viewModel: InverterFirmwareVersionsViewModel

    var body: some View {
        Section(
            content: {
                if let version = viewModel.version {
                    HStack {
                        Text("Manager: ") +
                            Text(version.manager)
                        Text("Slave: ") +
                            Text(version.slave)
                        Text("Master: ") +
                            Text(version.master)
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
        .task { viewModel.load() }
    }
}

struct InverterFirmwareVersionsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            InverterFirmwareVersionsView(viewModel: InverterFirmwareVersionsViewModel(config: MockConfigManager()))
        }
    }
}
