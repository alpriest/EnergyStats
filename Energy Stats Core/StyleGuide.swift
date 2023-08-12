//
//  StyleGuide.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 15/06/2023.
//

import SwiftUI

public extension Color {
    static var linesPositive: Color { Color("lines_positive", bundle: Bundle(for: CountdownTimer.self)) }
    static var linesNegative: Color { Color("lines_negative", bundle: Bundle(for: CountdownTimer.self)) }
    static var textPositive: Color { Color("text_positive", bundle: Bundle(for: CountdownTimer.self)) }
    static var textNegative: Color { Color("text_negative", bundle: Bundle(for: CountdownTimer.self)) }
    static var linesNotFlowing: Color { Color("lines_notflowing", bundle: Bundle(for: CountdownTimer.self)) }
    static var textNotFlowing: Color { Color("text_notflowing", bundle: Bundle(for: CountdownTimer.self)) }
    static var lightGray: Color { Color("light_gray", bundle: Bundle(for: CountdownTimer.self)) }
}

public class BundleLocator {}
