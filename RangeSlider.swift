//
//  RangeSlider.swift
//  
//
//  Created by Alistair Priest on 19/01/2026.
//

import Energy_Stats_Core
import SwiftUI

struct RangeSlider: View {
    @Binding var lower: Double
    @Binding var upper: Double
    let bounds: ClosedRange<Double>

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 6)

                Capsule()
                    .fill(.blue)
                    .frame(
                        width: position(for: upper, in: geo)
                            - position(for: lower, in: geo),
                        height: 6
                    )
                    .offset(x: position(for: lower, in: geo))
                
                thumb(value: $lower, geo: geo)
                thumb(value: $upper, geo: geo)
            }
        }
        .frame(height: 32)
    }

    private func position(for value: Double, in geo: GeometryProxy) -> CGFloat {
        let percent = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return percent * geo.size.width
    }

    private func thumb(value: Binding<Double>, geo: GeometryProxy) -> some View {
        Circle()
            .fill(.white)
            .frame(width: 24, height: 24)
            .shadow(radius: 2)
            .position(
                x: position(for: value.wrappedValue, in: geo),
                y: geo.size.height / 2
            )
            .gesture(
                DragGesture()
                    .onChanged { g in
                        let percent = min(max(0, g.location.x / geo.size.width), 1)
                        let newValue = bounds.lowerBound +
                            percent * (bounds.upperBound - bounds.lowerBound)
                        value.wrappedValue = newValue
                    }
            )
    }
}

#if DEBUG
struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSlider(lower: 2.0, upper: 5.0, bounds: 1...10)
    }
}
#endif
