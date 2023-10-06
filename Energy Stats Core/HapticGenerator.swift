//
//  HapticGenerator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/10/2023.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public final class ImpactHapticGenerator {
    #if os(iOS)
    private let haptic = UIImpactFeedbackGenerator()

    public init() {
        haptic.prepare()
    }

    public func impactOccurred() {
        haptic.impactOccurred()
    }

    public func selectionChanged() {
        haptic.selectionChanged()
    }
    #else
    public init() {}
    public func impactOccurred() {}
    public func selectionChanged() {}
    #endif
}
