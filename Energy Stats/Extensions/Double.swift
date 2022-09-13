//
//  Double.swift
//  Energy Stats
//
//  Created by Alistair Priest on 13/09/2022.
//

import Foundation

extension Double {
    func kW() -> String {
        String(format: "%0.2fkW", self)
    }
}
