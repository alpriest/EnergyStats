//
//  SettingsFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/08/2023.
//

import SwiftUI

struct SettingsFooterView: View {
    let username: String
    let onLogout: @MainActor () -> Void
    let appVersion: String

    var body: some View {
        Section(
            content: {
                VStack {
                    Text("You are logged in as ") + Text(username)
                    Button("logout") {
                        onLogout()
                    }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity)
            }, footer: {
                VStack(alignment: .center, spacing: 44) {
                    HStack {
                        Button {
                            let url = URL(string: "mailto:energystatsapp@gmail.com")!
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

                    Button {
                        let url = URL(string: "https://buymeacoffee.com/alpriest")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        Image(systemName: "cup.and.saucer")
                        Text("Buy me a coffee")
                    }

                    Button {
                        let url = URL(string: "https://paypal.me/alpriest")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        Text("Donate via")
                            .accessibilityValue("Donate via PayPal")
                        Image("paypal_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 16)
                            .accessibilityHidden(true)
                    }

                    Text("Version ") + Text(appVersion)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            })
    }
}

struct SettingsFooterView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SettingsFooterView(username: "bob priest",
                               onLogout: {},
                               appVersion: "1.23")
        }
    }
}