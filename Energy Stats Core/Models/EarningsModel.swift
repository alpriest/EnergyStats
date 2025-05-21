//
//  Earnings.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 29/08/2024.
//

import Foundation

public enum EarningsModel: Int, RawRepresentable {
    case exported = 0
    case generated = 1
    case ct2 = 2 // this is for battery-only Fox inverters which receive Solar input via CT2 and export that via a FiT
}
