//
//  IconScale 2.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/07/2025.
//

import Energy_Stats_Core
import SwiftUI

enum IconScale {
    case small
    case large

    var size: CGSize {
        switch self {
        case .small:
            CGSize(width: 32, height: 32)
        case .large:
            CGSize(width: 128, height: 128)
        }
    }

    var iconFont: Font {
        switch self {
        case .small:
            .system(size: 32)
        case .large:
            .system(size: 108)
        }
    }

    var line1Font: Font {
        switch self {
        case .small:
            .system(size: 16)
        case .large:
            .system(size: 24, weight: .bold)
        }
    }

    var line2Font: Font {
        switch self {
        case .small:
            .system(size: 14)
        case .large:
            .system(size: 20, weight: .bold)
        }
    }
}
