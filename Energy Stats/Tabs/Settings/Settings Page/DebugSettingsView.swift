//
//  DebugSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/04/2025.
//

import Energy_Stats_Core
import SwiftUI
import WormholySwift

struct DebugSettingsView: View {
    @State private var alert: AlertContent?
    let networking: Networking

    var body: some View {
        Form {
            Section {
                Button {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "wormholy_fire"), object: nil)
                } label: {
                    Text("Launch Wormholy")
                }
                .buttonStyle(.borderedProminent)
            } footer: {
                Text("Wormholy is included in the app to help with issues. It allows users to view their own network activity — like what data the app sends or receives — and optionally export it to share with the development team. This tool is only for troubleshooting and has no effect on how you use the app.")
            }

            Section {
                Button {
                    Task {
                        let counts = try await networking.fetchRequestCount()
                        alert = AlertContent(title: nil, message: LocalizedStringKey("\(counts.remaining) remaining out of \(counts.total) total"))
                    }
                } label: {
                    Text("View request count")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("View Debug Data")
        .analyticsScreen(.debug)
        .alert(alertContent: $alert)
    }
}

#Preview {
    NavigationView {
        DebugSettingsView(networking: NetworkService.preview())
    }
}
