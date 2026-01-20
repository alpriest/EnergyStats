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
    private let lowerBounds: ClosedRange<Double>
    private let upperBounds: ClosedRange<Double>

    private var overallBounds: ClosedRange<Double> {
        min(lowerBounds.lowerBound, upperBounds.lowerBound) ... max(lowerBounds.upperBound, upperBounds.upperBound)
    }

    private let step: Double = 1
    
    init(lower: Binding<Double>, upper: Binding<Double>, lowerBounds: ClosedRange<Double>, upperBounds: ClosedRange<Double>) {
        self._lower = lower
        self._upper = upper
        self.lowerBounds = lowerBounds
        self.upperBounds = upperBounds
    }

    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.gray.opacity(0.3))
                        .frame(height: 6)

                    tickMarks(in: geo)

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

            HStack {
                Text(String(describing: overallBounds.lowerBound.celsius))
                Spacer()
                Text(String(describing: overallBounds.upperBound.celsius))
            }
        }
    }

    private func position(for value: Double, in geo: GeometryProxy) -> CGFloat {
        let percent = (value - overallBounds.lowerBound) / (overallBounds.upperBound - overallBounds.lowerBound)
        return percent * geo.size.width
    }

    private func tickMarks(in geo: GeometryProxy) -> some View {
        let values = Array(stride(from: overallBounds.lowerBound, through: overallBounds.upperBound, by: step))

        return ZStack {
            ForEach(values, id: \.self) { value in
                Rectangle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 1, height: 10)
                    .position(
                        x: position(for: value, in: geo),
                        y: geo.size.height / 2
                    )
            }
        }
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
                        let rawValue = overallBounds.lowerBound +
                            percent * (overallBounds.upperBound - overallBounds.lowerBound)

                        let snapped = (rawValue / step).rounded() * step

                        if value.wrappedValue == lower {
                            // Lower thumb: respect lowerBounds and ordering against upper
                            var clamped = min(max(snapped, lowerBounds.lowerBound), lowerBounds.upperBound)
                            clamped = min(clamped, upper - step)
                            lower = clamped
                        } else {
                            // Upper thumb: respect upperBounds and ordering against lower
                            var clamped = min(max(snapped, upperBounds.lowerBound), upperBounds.upperBound)
                            clamped = max(clamped, lower + step)
                            upper = clamped
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
            RangeSlider(lower: $lower, upper: $upper, lowerBounds: -10 ... 10, upperBounds: -10 ... 10)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .padding()
    }
}
#endif
