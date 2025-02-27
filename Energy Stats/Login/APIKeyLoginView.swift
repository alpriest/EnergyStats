//
//  APIKeyLoginView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/01/2024.
//

import Energy_Stats_Core
import SwiftUI

struct APIKeyLoginView: View {
    @ObservedObject var userManager: UserManager
    @State private var apiKey = ""
    @State private var errorMessage: String?

    var body: some View {
        switch userManager.state {
        case let .active(localizedStringKey):
            LoadingView(message: localizedStringKey)
        default:
            loginView()
        }
    }

    func loginView() -> some View {
        VStack {
            Text("Enter your FoxESS Cloud API key")
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding()

            SecureTextField("API Key", text: $apiKey)
                .font(.system(size: 13))
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            if let errorMessage {
                HStack {
                    AlertIconView()
                        .frame(width: 30, height: 30)

                    Text(errorMessage)
                }
                .padding(.vertical)
            }

            HStack {
                Button("Try demo") {
                    Task { await userManager.login(apiKey: "demo") }
                }
                .accessibilityIdentifier("try_demo")
                .padding()
                .buttonStyle(.bordered)

                Button("Log me in") {
                    Task { await userManager.login(apiKey: apiKey.trimmingCharacters(in: .whitespaces)) }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }

            HowToObtainAPIKeyView()
        }
        .padding()
        .onReceive(userManager.$state) { state in
            if case let .error(error, message) = state {
                if let cause = error as? NetworkError,
                   case NetworkError.invalidToken = cause
                {
                    errorMessage = "Your API token is invalid."
                } else {
                    errorMessage = message
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    APIKeyLoginView(userManager: UserManager.preview())
}
#endif
