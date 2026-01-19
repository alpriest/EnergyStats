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
    private let step: Double = 1

    var body: some View {
        VStack {
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

            HStack {
                Text("\(Int(bounds.lowerBound))")
                Spacer()
                Text("\(Int(bounds.upperBound))")
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
            .overlay(Text("\(Int(value.wrappedValue))").font(.caption2))
            .position(
                x: position(for: value.wrappedValue, in: geo),
                y: geo.size.height / 2
            )
            .gesture(
                DragGesture()
                    .onChanged { g in
                        let percent = min(max(0, g.location.x / geo.size.width), 1)
                        let rawValue = bounds.lowerBound +
                            percent * (bounds.upperBound - bounds.lowerBound)

                        let snapped = (rawValue / step).rounded() * step
                        let clamped = min(max(snapped, bounds.lowerBound), bounds.upperBound)

                        if value.wrappedValue == lower {
                            // Dragging lower thumb – it cannot exceed (upper - step)
                            lower = min(clamped, upper - step)
                            // Also ensure we don't go out of bounds if bounds are tight
                            lower = max(lower, bounds.lowerBound)
                        } else {
                            // Dragging upper thumb – it cannot go below (lower + step)
                            upper = max(clamped, lower + step)
                            // Also ensure we don't go out of bounds if bounds are tight
                            upper = min(upper, bounds.upperBound)
                        }
                    }
            )
    }
}

#if DEBUG
struct RangeSlider_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var lower: Double = 2
        @State var upper: Double = 5

        var body: some View {
            RangeSlider(lower: $lower, upper: $upper, bounds: -10 ... 10)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .padding()
    }
}
#endif
