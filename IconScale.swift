//
//  IconScale.swift
//
//
//  Created by Alistair Priest on 30/06/2025.
//

import Energy_Stats_Core
import SwiftUI

enum IconScale {
    case small
    case large

    var size: CGSize {
        switch self {
        case .small:
            CGSize(width: 34, height: 34)
        case .large:
            CGSize(width: 128, height: 128)
        }
    }

    var iconFont: Font {
        switch self {
        case .small:
            .system(size: 36)
        case .large:
            .system(size: 108)
        }
    }

    var font: Font {
        switch self {
        case .small:
            .system(size: 16)
        case .large:
            .system(size: 24, weight: .bold)
        }
    }
}
