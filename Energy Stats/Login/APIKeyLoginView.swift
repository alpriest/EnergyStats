//
//  APIKeyLoginView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/01/2024.
//

import SwiftUI

struct APIKeyLoginView: View {
    @ObservedObject var userManager: UserManager
    @State private var apiKey = ""

    var body: some View {
        ScrollView {
            VStack {
                Text("Enter your FoxESS Cloud details")
                    .multilineTextAlignment(.center)
                    .font(.headline)
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
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }.padding()

            HowToObtainAPIKeyView()
        }
        .padding()
        .loadable(userManager.state, retry: { Task { await userManager.login(apiKey: apiKey) } })
    }
}

#if DEBUG
#Preview {
    APIKeyLoginView(userManager: UserManager.preview())
}
#endif
