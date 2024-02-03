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
            
            VStack(alignment: .leading) {
                Text("To get your API key:")
                    .padding(.bottom, 8)
                
                Text("1. Login at https://www.foxesscloud.com/")
                Text("2. Click the person icon top-right")
                Text("3. Click the User Profile menu option")
                Text("4. Click Generate API key")
                Text("5. Copy the API key (make a note of it securely)")
                Text("6. Paste the API key above")

                Text("api_key_change_reason")
                    .font(.caption2)
                    .padding(.top)
            }
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
