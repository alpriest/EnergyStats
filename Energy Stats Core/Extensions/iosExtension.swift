//
//  iosExtension.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/10/2023.
//

import Foundation
import SwiftUI

#if os(iOS)
struct CopyButton: View {
    let text: String

    var body: some View {
        Button(action: {
            UIPasteboard.general.string = text
        }) {
            Image(systemName: "doc.on.doc")
        }
    }
}
#endif

public struct NavBarCopyButton: ViewModifier {
    let text: String

    public func body(content: Content) -> some View {
#if os(iOS)
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CopyButton(text: text)
                }
            }
#else
        content
#endif
    }
}

public struct InlineNavigationBarTitleDisplayMode: ViewModifier {
    public func body(content: Content) -> some View {
#if os(iOS)
        content.navigationBarTitleDisplayMode(.inline)
#else
        content
#endif
    }
}

public struct DisableAutoCapitalization: ViewModifier {
    public func body(content: Content) -> some View {
#if os(iOS)
        content.autocapitalization(.none)
#else
        content
#endif
    }
}

public struct NumberPadKeyboardType: ViewModifier {
    public func body(content: Content) -> some View {
#if os(iOS)
        content.keyboardType(.numberPad)
#else
        content
#endif
    }
}

public extension View {
    func disableAutoCapitalization() -> some View {
        modifier(DisableAutoCapitalization())
    }

    func inlineNavigationBarTitle() -> some View {
        modifier(InlineNavigationBarTitleDisplayMode())
    }

    func numberPadKeyboardType() -> some View {
        modifier(NumberPadKeyboardType())
    }

    func navBarCopyButton(text: String) -> some View {
        modifier(NavBarCopyButton(text: text))
    }
}
