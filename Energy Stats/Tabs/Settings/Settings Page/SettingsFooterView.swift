//
//  SettingsFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SettingsFooterView: View {
    let configManager: ConfigManaging
    let onLogout: @MainActor () -> Void
    let appVersion: String

    var body: some View {
        Section(
            content: {
                VStack {
                    Button(
                        configManager.isDemoUser ? "logout from demo" : "logout"
                    ) {
                        onLogout()
                    }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity)
            }, footer: {
                VStack(alignment: .center, spacing: 44) {
                    HStack {
                        Button {
                            let url = URL(string: "mailto:energystatsapp@gmail.com?subject=iOS%20App%20\(appVersion)")!
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } label: {
                            Image(systemName: "envelope")
                            Text("Get in touch")
                        }
                    }
                    .padding(.top, 88)

                    Button {
                        let url = URL(string: "itms-apps://itunes.apple.com/app/id1644492526?action=write-review")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        Image(systemName: "medal")
                        Text("Rate this app")
                            .multilineTextAlignment(.center)
                    }

                    Text("Version ") + Text(appVersion)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        )
    }
}

struct SettingsFooterView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SettingsFooterView(configManager: ConfigManager.preview(),
                               onLogout: {},
                               appVersion: "1.23")
        }
    }
}
