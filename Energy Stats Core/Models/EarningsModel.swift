//
//  Earnings.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 29/08/2024.
//

import Foundation

public enum EarningsModel: Int {
    case exported
    case generated

    public func title() -> String {
        switch self {
        case .exported:
            return String(localized: "Exported")
        case .generated:
            return String(localized: "Generated")
        }
    }
}
