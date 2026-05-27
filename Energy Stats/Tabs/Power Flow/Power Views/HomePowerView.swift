//
//  HomePowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct HomePowerView: View, VerticalSizeClassProviding {
    let amount: Double
    let appSettings: AppSettings
    @Environment(\.verticalSizeClass) public var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack {
            PowerFlowView(
                amount: amount,
                appSettings: appSettings,
                showColouredLines: false,
                type: .homeFlow,
                verticalAlignment: VerticalConstraint.isConstrained(dynamicTypeSize: dynamicTypeSize, appSettings: appSettings) ? .bottom : .center
            )

            Image(systemName: "house.fill")
                .resizable()
                .frame(width: length, height: length)
                .padding(.bottom, 1)
                .accessibilityHint("Home")
        }
    }

    private var length: CGFloat {
        shouldReduceIconSize ? 40 : 45
    }
}

#Preview {
    HomePowerView(amount: 1.05,
                  appSettings: AppSettings.mock())
        .frame(width: 50, height: 220)
}
