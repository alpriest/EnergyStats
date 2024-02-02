//
//  UpgradeRequiredView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/01/2024.
//

import SwiftUI

struct UpgradeRequiredView: View {
    let userManager: UserManager

    var body: some View {
        VStack(spacing: 44) {
            Text("IMPORTANT")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("We've updated the login process for Energy Stats")
                .font(.title)
                .fontWeight(.bold)

            Button("Continue") {
                userManager.logout()
            }.buttonStyle(.borderedProminent)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("What's changed?")
                    .font(.title3)

                Text("In December 2023, FoxESS asked all 3rd party integrations use a migrate access to a new set of services to access customer data. These new services are known by FoxESS as their OpenAPI services.")

                Text("These new services are different from those used by the Fox apps and have some notable differences.")

                Text("- **Rate limited to 1,440 requests per inverter per day**. Unless you leave Energy Stats on 24 hours a day this is unlikely to affect you.")
                Text("- **Schedule templates are no longer available** as FoxESS have not yet made these available via their OpenAPI. When schedule templates become available support will be added.")
                Text("- **Login is via an API key**. Instructions for finding your API key are on the login page.")
            }
            .font(.caption)
        }.padding()
    }
}

#if DEBUG
#Preview {
    UpgradeRequiredView(userManager: .preview())
}
#endif
