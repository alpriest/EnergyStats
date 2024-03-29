//
//  AlertContentView.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/12/2023.
//

import SwiftUI

struct AlertContentView: ViewModifier {
    @Binding var alertContent: AlertContent?

    private var showing: Binding<Bool> {
        Binding(
            get: {
                alertContent != nil
            },
            set: { _ in alertContent = nil }
        )
    }

    init(alertContent: Binding<AlertContent?>) {
        self._alertContent = alertContent
    }

    func body(content: Content) -> some View {
        content
            .alert(isPresented: showing) {
                if let alertContent {
                    return Alert(title: Text(alertContent.title ?? ""),
                                 message: Text(alertContent.message),
                                 dismissButton: .default(
                                     Text("OK"),
                                     action: alertContent.onDismiss
                                 ))
                } else {
                    return Alert(title: Text(""))
                }
            }
    }
}

public extension View {
    func alert(alertContent: Binding<AlertContent?>) -> some View {
        modifier(AlertContentView(alertContent: alertContent))
    }
}

struct AlertContent_Previews: PreviewProvider {
    static var previews: some View {
        Other()
    }

    private struct Other: View {
        @State var content: AlertContent?

        var body: some View {
            Button {
                content = AlertContent(title: "Hello", message: "Long message")
            } label: {
                Text("Click me")
            }
            .modifier(AlertContentView(alertContent: $content))
        }
    }
}
