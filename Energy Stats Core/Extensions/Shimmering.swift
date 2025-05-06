//
//  Shimmering.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/06/2024.
//

import SwiftUI

public struct ShimmerConfiguration {
    public let gradient: Gradient
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    public let duration: TimeInterval
    public let opacity: Double
    public let delay: TimeInterval

    public static let `default` = ShimmerConfiguration(
        gradient: Gradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .white, location: 0.3),
            .init(color: .white, location: 0.7),
            .init(color: .black, location: 1),
        ]),
        initialLocation: (start: UnitPoint(x: -1, y: 0.4), end: .leading),
        finalLocation: (start: .trailing, end: UnitPoint(x: 2, y: 0.3)),
        duration: 2,
        opacity: 0.6,
        delay: 1.5
    )
}

public struct ShimmeringView<Content: View>: View {
    private let content: () -> Content
    private let configuration: ShimmerConfiguration
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    @Environment(\.colorScheme) private var colorScheme

    public init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
        self.configuration = configuration
        self.content = content
        _startPoint = .init(wrappedValue: configuration.initialLocation.start)
        _endPoint = .init(wrappedValue: configuration.initialLocation.end)
    }

    public var body: some View {
        content()
            .overlay(
                LinearGradient(
                    gradient: configuration.gradient,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .opacity(configuration.opacity)
                .blendMode(colorScheme == .dark ? .multiply : .screen)
                .onAppear {
                    withAnimation(Animation.linear(duration: configuration.duration).delay(configuration.delay).repeatForever(autoreverses: false)) {
                        startPoint = configuration.finalLocation.start
                        endPoint = configuration.finalLocation.end
                    }
                }
            )
    }
}

public struct ShimmerModifier: ViewModifier {
    let configuration: ShimmerConfiguration

    public func body(content: Content) -> some View {
        ShimmeringView(configuration: configuration) { content }
    }
}

public extension View {
    func redactedShimmer(when condition: @autoclosure () -> Bool) -> some View {
        Group {
            redacted(reason: condition() ? .placeholder : [])
                .if(condition()) {
                    $0.modifier(ShimmerModifier(configuration: .default))
                }
        }
    }

    func shimmer(configuration: ShimmerConfiguration = .default) -> some View {
        modifier(ShimmerModifier(configuration: configuration))
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EnergyText(amount: nil, appSettings: AppSettings.mock(), type: .homeUsage)

            Text("Usage today")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(Color("text_dimmed"))
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}
