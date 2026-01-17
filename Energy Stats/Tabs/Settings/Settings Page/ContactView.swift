//
//  ContactView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/01/2026.
//

import SwiftUI

struct ContactView: View {
    let appVersion: String

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("contact.header.techsupport")) {
                    ExternalWebNavigationLink(url: "https://www.foxesscommunity.com") {
                        Text(String(key: .foxessCommunity))
                    }
                    ExternalWebNavigationLink(url: "https://www.facebook.com/groups/foxessownersgroup") { Text(String(key: .facebookGroup))
                    }
                }

                Section(header: Text("contact.header.faq")) {
                    NavigationLink(destination: FAQView()) {
                        Text("settings.faq")
                    }
                }

                Section(header: Text("contact.header.getintouch"),
                        footer: Text("contact.footer.getintouch")) {
                    Button {
                        let url = URL(string: "mailto:energystatsapp@gmail.com?subject=iOS%20App%20\(appVersion)")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        Text("Send an email")
                    }
                }
                
                Section(footer: Text("contact.footer.author")) { }
            }
            .navigationTitle("Contact")
        }
    }
}

#Preview {
    ContactView(appVersion: "1.2")
}
