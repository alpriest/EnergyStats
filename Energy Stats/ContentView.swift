//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loginManager: UserManager
    let network: Network

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, userManager: loginManager)
        } else {
            LoginView(loginManager: loginManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            loginManager: UserManager(networking: MockNetworking(), store: KeychainStore()),
            network: MockNetworking()
        )
    }
}
