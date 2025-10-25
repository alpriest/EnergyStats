//
//  NumberRollerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/10/2025.
//

import SwiftUI

public struct NumberRollerView: View {
    @State private var target = ""
    private let rowHeight: CGFloat
    private let columnWidth: CGFloat
    private let uiFont = UIFont.monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    private func width(of s: String) -> CGFloat {
        (s as NSString).size(withAttributes: [.font: uiFont]).width.rounded(.up)
    }

    public init(text: String) {
        target = text
        rowHeight = ("8" as NSString).size(withAttributes: [.font: uiFont]).height.rounded(.up)
        columnWidth = ("0" as NSString).size(withAttributes: [.font: uiFont]).width.rounded(.up)
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Array(target.enumerated()), id: \.offset) { index, char in
                if let d = char.wholeNumberValue {
                    DigitRoller(
                        digit: d,
                        delay: Double(index) * 0.12,
                        rowHeight: rowHeight,
                        columnWidth: columnWidth
                    )
                } else {
                    let s = String(char)
                    Text(s)
                        .lineLimit(1)
                        .fixedSize()
                        .frame(width: width(of: s), height: rowHeight, alignment: .center)
                        .alignmentGuide(.firstTextBaseline) { d in d[.lastTextBaseline] }
                }
            }
        }
        .frame(height: rowHeight) // show exactly one row
        .font(Font(uiFont))
        .monospacedDigit()
        .mask(
            LinearGradient(stops: [
                Gradient.Stop(color: Color.clear, location: 0.0),
                Gradient.Stop(color: Color.black, location: 0.15),
                Gradient.Stop(color: Color.black, location: 0.85),
                Gradient.Stop(color: Color.clear, location: 1.0)
            ], startPoint: .top, endPoint: .bottom)
        )
    }
}

struct DigitRoller: View {
    private let digit: Int
    private let delay: Double
    private let rowHeight: CGFloat
    private let columnWidth: CGFloat
    private let spins: Int = 2
    
    init(digit: Int, delay: Double, rowHeight: CGFloat, columnWidth: CGFloat) {
        self.digit = digit
        self.delay = delay
        self.rowHeight = rowHeight
        self.columnWidth = columnWidth
    }

    @State private var extraOffset: CGFloat = 0 // start scrolled well above 0 to simulate a spin

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...9, id: \.self) { n in
                Text(String(n))
                    .lineLimit(1)
                    .fixedSize()
                    .frame(width: columnWidth, height: rowHeight, alignment: .center)
            }
        }
        // Base offset positions the wheel at the target digit; extraOffset provides the animated spin
        .offset(y: (-CGFloat(digit) * rowHeight + extraOffset).rounded())
        .frame(width: columnWidth, height: rowHeight, alignment: .top)
        .clipped()
        // Align the visible digit baseline with surrounding text
        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
        .onAppear {
            // Jump (no animation) to several full cycles above the target, then spring down to land exactly on `digit`.
            withTransaction(Transaction(animation: nil)) {
                extraOffset = -CGFloat(spins * 10) * rowHeight // 10 rows per full cycle (0-9)
            }
            withAnimation(.interpolatingSpring(stiffness: 140, damping: 14).delay(delay)) {
                extraOffset = 0 // final resting state shows `digit`
            }
        }
    }
}
