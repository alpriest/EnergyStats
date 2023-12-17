//
//  BottomButtonsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/08/2023.
//

import SwiftUI

struct BottomButtonLabels {
    let left: LocalizedStringKey
    let right: LocalizedStringKey

    static var defaults: BottomButtonLabels {
        BottomButtonLabels(left: "Cancel", right: "Apply")
    }
}

struct BottomButtonsView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    private let onApply: () -> Void
    private let onCancel: (() -> Void)?
    private let footer: () -> Content
    private let labels: BottomButtonLabels

    init(
        labels: BottomButtonLabels = .defaults,
        onApply: @escaping () -> Void,
        onCancel: (() -> Void)? = nil,
        @ViewBuilder footer: @escaping () -> Content = { EmptyView() }
    ) {
        self.onApply = onApply
        self.onCancel = onCancel
        self.footer = footer
        self.labels = labels
    }

    var body: some View {
        VStack(spacing: 0) {
            Color("BottomBarDivider")
                .frame(height: 1)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: {
                    if let onCancel { onCancel() } else { dismiss() }
                }) {
                    Text(labels.left)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("cancel")

                Button(action: {
                    onApply()
                }) {
                    Text(labels.right)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }

            footer()
        }
    }
}

#Preview {
    BottomButtonsView {}
}
