//
//  Double.swift
//  Energy Stats
//
//  Created by Alistair Priest on 13/09/2022.
//

import Foundation

extension Double {
    func kW() -> String {
        let places = 2
        let divisor = pow(10.0, Double(places))
        let divided = (self * divisor).rounded() / divisor

        return String(format: "%0.2fkW", divided)
    }
}
