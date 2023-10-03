//
//  BottomButtonsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/08/2023.
//

import SwiftUI

struct BottomButtonsView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    private let onApply: () -> Void
    private let onCancel: (() -> Void)?
    private let footer: () -> Content

    init(onApply: @escaping () -> Void, onCancel: (() -> Void)? = nil, @ViewBuilder footer: @escaping () -> Content = { EmptyView() }) {
        self.onApply = onApply
        self.onCancel = onCancel
        self.footer = footer
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
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("cancel")

                Button(action: {
                    onApply()
                }) {
                    Text("Apply")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }

            footer()
        }
    }
}

struct BottomButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        BottomButtonsView {}
    }
}
