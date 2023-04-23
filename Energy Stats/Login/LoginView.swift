//
//  LoginView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import SwiftUI
import Energy_Stats_Core

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @ObservedObject var loginManager: UserManager

    var body: some View {
        VStack {
            Text("Enter your FoxESS Cloud details")
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            HStack {
                Button("Try demo") {
                    Task { await loginManager.login(username: "demo", password: "user") }
                }
                .accessibilityIdentifier("try_demo")
                .padding()
                .buttonStyle(.bordered)

                Button("Log me in") {
                    Task { await loginManager.login(username: username, password: password) }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .loadable($loginManager.state) {
            Task { await loginManager.login(username: username, password: password) }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: PreviewConfigManager()))
    }
}
