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
    @ObservedObject var userManager: UserManager

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
                    Task { await userManager.login(username: "demo", password: "user") }
                }
                .accessibilityIdentifier("try_demo")
                .padding()
                .buttonStyle(.bordered)

                Button("Log me in") {
                    Task { await userManager.login(username: username, password: password) }
                }
                .disabled(loginDisabled)
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .loadable($userManager.state) {
            userManager.state = .inactive
        }
    }

    var loginDisabled: Bool {
        username.isEmpty || password.isEmpty
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userManager: .preview())
    }
}
