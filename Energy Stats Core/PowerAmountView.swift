//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import Combine
import SwiftUI

public enum AmountType {
    case solarFlow
    case batteryFlow
    case batteryCapacity
    case homeFlow
    case gridFlow
    case selfSufficiency
    case totalYield
    case `default`

    func accessibilityLabel(amount: Double, amountWithUnit: String) -> String {
        switch self {
        case .solarFlow:
            return "Solar currently generating \(amountWithUnit)"
        case .batteryFlow:
            if amount > 0 {
                return "Battery storing \(amountWithUnit)"
            } else {
                return "Battery emptying \(amountWithUnit)"
            }
        case .batteryCapacity:
            return "Battery capacity \(amountWithUnit)"
        case .homeFlow:
            return "Home consuming \(amountWithUnit)"
        case .gridFlow:
            if amount > 0 {
                return "Exporting \(amountWithUnit) to grid"
            } else {
                return "Importing \(amountWithUnit) from grid"
            }
        case .selfSufficiency:
            return amountWithUnit
        case .totalYield:
            return "Yield today \(amountWithUnit)"
        case .default:
            return amountWithUnit
        }
    }
}

public struct PowerText: View {
    let amount: Double
    let appTheme: AppTheme
    let type: AmountType

    public init(amount: Double, appTheme: AppTheme, type: AmountType) {
        self.amount = amount
        self.appTheme = appTheme
        self.type = type
    }

    public var body: some View {
        Text(amountWithUnit)
            .accessibilityLabel(type.accessibilityLabel(amount: amount, amountWithUnit: amountWithUnit))
    }

    private var amountWithUnit: String {
        if appTheme.showInW {
            return amount.w()
        } else {
            return amount.kW(appTheme.decimalPlaces)
        }
    }
}

public struct EnergyText: View {
    let amount: Double
    let appTheme: AppTheme
    let type: AmountType

    public init(amount: Double, appTheme: AppTheme, type: AmountType) {
        self.amount = amount
        self.appTheme = appTheme
        self.type = type
    }

    public var body: some View {
        Text(amountWithUnit)
            .accessibilityLabel(type.accessibilityLabel(amount: amount, amountWithUnit: amountWithUnit))
    }

    private var amountWithUnit: String {
        if appTheme.showInW {
            return amount.wh()
        } else {
            return amount.kWh(appTheme.decimalPlaces)
        }
    }
}

public struct PowerAmountView: View {
    public let amount: Double
    public let backgroundColor: Color
    public let textColor: Color
    public let appTheme: AppTheme
    public let type: AmountType

    public init(amount: Double, backgroundColor: Color, textColor: Color, appTheme: AppTheme, type: AmountType) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.appTheme = appTheme
        self.type = type
    }

    public var body: some View {
        Group {
            PowerText(amount: amount, appTheme: appTheme, type: type)
        }
        .padding(3)
        .padding(.horizontal, 4)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(3)
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        PowerAmountView(amount: 0.310, backgroundColor: .red, textColor: .black, appTheme: AppTheme.mock(), type: .solarFlow)
    }
}

public extension AppTheme {
    static func mock(decimalPlaces: Int = 3, showInW: Bool = false, showInverterTemperature: Bool = false) -> AppTheme {
        AppTheme(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: decimalPlaces,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            showInW: showInW,
            showTotalYield: false,
            selfSufficiencyEstimateMode: .off,
            showEarnings: false,
            showInverterTemperature: showInverterTemperature
        )
    }
}
