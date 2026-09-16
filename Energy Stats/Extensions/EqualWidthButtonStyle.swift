import Energy_Stats_Core
import SwiftUI

struct EqualWidthButtonWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EqualWidthButtonWidthReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: EqualWidthButtonWidthPreferenceKey.self,
                    value: geometry.size.width
                )
        }
    }
}

struct EqualWidthButtonStyle: ButtonStyle {
    let buttonWidth: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: buttonWidth)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(colorScheme == .dark ? Color.white.opacity(0.14) : Color.paleGray)
            .foregroundStyle(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
