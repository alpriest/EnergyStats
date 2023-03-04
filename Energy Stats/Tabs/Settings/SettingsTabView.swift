//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

class SettingsTabViewModel: ObservableObject {
    @Published var useColouredLines: Bool {
        didSet {
            config.useColouredLines = useColouredLines
        }
    }

    private var config: ConfigManaging
    private let userManager: UserManager

    init(userManager: UserManager, config: ConfigManaging) {
        self.userManager = userManager
        self.config = config
        useColouredLines = config.useColouredLines
    }

    var minSOC: Double { config.minSOC }
    var batteryCapacity: Int { config.batteryCapacity }
    var username: String { userManager.getUsername() ?? "" }

    @MainActor
    func logout() {
        userManager.logout()
    }
}

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Min SOC")
                    Spacer()
                    Text(viewModel.minSOC, format: .percent)
                }

                HStack {
                    Text("Capacity")
                    Spacer()
                    Text(viewModel.batteryCapacity, format: .number)
                    Text("kW")
                }
            }, header: {
                Text("Battery")
            }, footer: {
                Text("These values are automatically calculated from your installation. If your battery is below min SOC then the total capacity calculation will be incorrect.")
            })

            Section(content: {
                HStack {
                    Toggle(isOn: $viewModel.useColouredLines) {
                        Text("Use coloured flow lines")
                    }
                }
            })

            Section(content: {
                VStack {
                    Text("You are logged in as \(viewModel.username)")
                    Button("logout") {
                        viewModel.logout()
                    }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity)
            }, footer: {
                VStack {
                    HStack {
                        Image(systemName: "envelope")
                        Button("Get in touch with us") {
                            UIApplication.shared.open(URL(string: "mailto:energystatsapp@gmail.com")!)
                        }
                    }
                }
                .padding(.top, 88)
                .frame(maxWidth: .infinity)
            })
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(viewModel: SettingsTabViewModel(
            userManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: MockConfigManager()),
            config: MockConfigManager())
        )
    }
}
