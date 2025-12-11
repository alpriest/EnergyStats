//
//  DebugSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/04/2025.
//

import Energy_Stats_Core
import SwiftUI
import PulseUI

struct DebugSettingsView: View {
    @State private var alert: AlertContent?
    @State private var isPulseShowing = false
    let networking: Networking

    var body: some View {
        Form {
            Section {
                Button {
                    isPulseShowing.toggle()
                } label: {
                    Text("Launch Pulse")
                }
                .buttonStyle(.borderedProminent)
            } footer: {
                Text("Pulse is included in the app to help with issues. It allows users to view their own network activity — like what data the app sends or receives — and optionally export it to share with the development team. This tool is only for troubleshooting and has no effect on how you use the app.")
            }

            Section {
                Button {
                    Task {
                        let counts = try await networking.fetchRequestCount()
                        await MainActor.run {
                            alert = AlertContent(title: nil, message: LocalizedStringKey("\(counts.remaining) remaining out of \(counts.total) total"))
                        }
                    }
                } label: {
                    Text("View request count")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $isPulseShowing) {
            NavigationView {
                ConsoleView()
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
