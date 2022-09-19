//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loginManager: LoginManager
    let network: Network
    let credentials: KeychainStore

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, credentials: credentials)
        } else {
            LoginView(loginManager: loginManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            loginManager: LoginManager(networking: MockNetworking(), store: KeychainStore()),
            network: MockNetworking(),
            credentials: KeychainStore()
        )
    }
}
