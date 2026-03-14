//
//  ToastView.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 14/03/2026.
//

import SwiftUI

public protocol HasToastContent: AnyObject {
    var toastContent: ToastContent? { get set }
}

public extension HasToastContent {
    @MainActor
    func setAlertContent(_ toastContent: ToastContent) async {
        self.toastContent = toastContent
    }
}

public struct ToastContent {
    public let message: LocalizedStringKey

    public init(message: LocalizedStringKey) {
        self.message = message
    }
}

private struct ToastOverlay: View {
    @Binding var content: ToastContent?

    init(content: Binding<ToastContent?>) {
        self._content = content
    }

    private var showing: Binding<Bool> {
        Binding(
            get: {
                content != nil
            },
            set: { _ in content = nil }
        )
    }
    
    var body: some View {
        VStack {
            Spacer()

            if showing.wrappedValue, let content {
                Text(content.message)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: showing.wrappedValue) {
                        guard showing.wrappedValue else { return }
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                showing.wrappedValue = false
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: showing.wrappedValue)
        .allowsHitTesting(false)
    }
}

private struct ToastModifier: ViewModifier {
    let toastContent: Binding<ToastContent?>

    func body(content: Content) -> some View {
        content
            .overlay {
                ToastOverlay(content: toastContent)
            }
    }
}

public extension View {
    func toast(_ toastContent: Binding<ToastContent?>) -> some View {
        modifier(ToastModifier(toastContent: toastContent))
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var toastContent: ToastContent? = nil

        var body: some View {
            VStack {
                Button("Tap") {
                    withAnimation(.easeInOut) {
                        toastContent = ToastContent(message: .init("Hello, world!"))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toast($toastContent)
        }
    }

    return PreviewHost()
}
