//
//  LoginView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct LoginView: View {
    @State private var apiKey: String = ""
    @ObservedObject var userManager: UserManager

    var body: some View {
        VStack {
            VStack {
                Text("Enter your FoxESS Cloud API key")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(.bottom)

                Text("where_to_find_api_key")
                    .multilineTextAlignment(.center)
                    .font(.caption)
            }
            .padding()

            TextField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            HStack {
                Button("Try demo") {
                    Task { await userManager.login(apiKey: "demo") }
                }
                .accessibilityIdentifier("try_demo")
                .padding()
                .buttonStyle(.bordered)

                Button("Log me in") {
                    Task { await userManager.login(apiKey: apiKey) }
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

    private var loginDisabled: Bool {
        apiKey.isEmpty
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userManager: .preview())
    }
}
#endif
