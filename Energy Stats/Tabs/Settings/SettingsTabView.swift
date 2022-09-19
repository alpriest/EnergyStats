//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct SettingsTabView: View {
    let credentials: KeychainStore

    var body: some View {
        VStack(spacing: 44) {
            Text("You are logged in as \(credentials.getUsername() ?? "")")

            Button("logout") {
                credentials.logout()
            }.buttonStyle(.bordered)
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(credentials: KeychainStore())
    }
}
