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

    static func scheduleColor(named name: WorkMode) -> Color {
        let mapping: [WorkMode: Color] = [
            .Feedin: Color.linesPositive,
            .ForceCharge: Color.linesNegative,
            .ForceDischarge: Color.linesPositive,
            .SelfUse: Color.paleGray
        ]

        return mapping[name] ?? Color.black
    }

    static func deviceStateColor(_ deviceState: DeviceState) -> Color {
        switch deviceState {
        case .online:
            Color.gray
        case .fault:
            Color("lines_negative")
        case .offline:
            Color("lines_negative")
        }
    }
}

public class BundleLocator {}
