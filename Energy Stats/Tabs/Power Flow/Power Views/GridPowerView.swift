//
//  GridPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct GridPowerView: View, VerticalSizeClassProviding {
    let amount: Double
    let appSettings: AppSettings
    @Environment(\.verticalSizeClass) public var verticalSizeClass

    var body: some View {
        VStack {
            PowerFlowView(
                amount: amount,
                appSettings: appSettings,
                showColouredLines: true,
                type: .gridFlow,
                verticalAlignment: UIWindowScene.isVerticallyConstrained ? .bottom : .center
            )
            PylonView(lineWidth: 3)
                .frame(width: length, height: length)
        }
    }

    private var length: CGFloat {
        shouldReduceIconSize ? 36 : 45
    }
}

#Preview {
    GridPowerView(amount: 0.4,
                  appSettings: AppSettings.mock())
}
