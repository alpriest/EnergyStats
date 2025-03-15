//
//  View+IconSize.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/03/2025.
//

import SwiftUI

public protocol VerticalSizeClassProviding {
    var verticalSizeClass: UserInterfaceSizeClass? { get }
}

public extension VerticalSizeClassProviding {
    var shouldReduceIconSize: Bool {
        verticalSizeClass == .compact
    }
}
