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

        VStack(alignment: .leading) {
            Text("To get your API key:")
                .padding(.bottom, 8)

            Text("1. Login at https://www.foxesscloud.com/")
            Text("2. Click the person icon top-right")
            Text("3. Click the User Profile menu option")
            Text("4. Click Generate API key")
            Text("5. Copy the API key (make a note of it securely)")
            Text("6. Paste the API key above")

            Text("This change to API key was required by FoxESS in January 2024. The FoxESS site does not function well on mobile devices. Please do not contact Energy Stats with issues about the FoxESS website, only FoxESS will be able to assist you in any issues with their site. service.uk@fox-ess.com")
                .font(.caption2)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    APIKeyLoginView(userManager: UserManager.preview())
}
