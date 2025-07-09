//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import Combine
import SwiftUI

public struct PowerAmountView: View {
    public let amount: Double
    public let backgroundColor: Color
    public let textColor: Color
    public let appSettings: AppSettings
    public let type: AmountType

    public init(amount: Double, backgroundColor: Color, textColor: Color, appSettings: AppSettings, type: AmountType) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.appSettings = appSettings
        self.type = type
    }

    public var body: some View {
        Group {
            PowerText(amount: amount, appSettings: appSettings, type: type)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 3)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(3)
    }
}

#Preview {
    VStack {
        PowerText(amount: nil, appSettings: .mock(), type: .default)
        EnergyText(amount: nil, appSettings: .mock(), type: .default)
    }
}
