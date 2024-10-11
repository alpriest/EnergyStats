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
    static var linesNotFlowing: Color { Color("lines_not_flowing", bundle: Bundle(for: CountdownTimer.self)) }
    static var textNotFlowing: Color { Color("text_not_flowing", bundle: Bundle(for: CountdownTimer.self)) }
    static var paleGray: Color { Color("pale_gray", bundle: Bundle(for: CountdownTimer.self)) }
    static var background: Color { Color("background", bundle: Bundle(for: CountdownTimer.self)) }
    static var iconDisabled: Color { Color("Sun_Zero", bundle: Bundle(for: CountdownTimer.self)) }
    static var loadsPower: Color { Color("loads_power", bundle: Bundle(for: CountdownTimer.self)) }
    #if iOS
    static var label: Color { Color(uiColor: .label) }
    #endif

    static func scheduleColor(named name: WorkMode) -> Color {
        let mapping: [WorkMode: Color] = [
            .Feedin: Color.linesPositive,
            .ForceCharge: Color.linesNegative,
            .ForceDischarge: Color.linesPositive,
            .SelfUse: Color.paleGray
        ]

        return mapping[name] ?? Color.black
    }
}

public class BundleLocator {}
