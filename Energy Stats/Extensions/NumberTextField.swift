//
//  NumberTextField.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct NumberTextField<Field: Hashable>: View {
    let title: String
    @Binding var text: String
    let focusedField: FocusState<Field?>.Binding
    let equals: Field

    init(
        _ title: String,
        text: Binding<String>,
        focusedField: FocusState<Field?>.Binding,
        equals: Field
    ) {
        self.title = title
        self._text = text
        self.focusedField = focusedField
        self.equals = equals
    }

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.numberPad)
            .focused(focusedField, equals: equals)
            .onChange(of: text, perform: { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    text = filtered
                }
            })
    }
}

#Preview {
    struct Preview: View {
        @State var value = "12"
        @FocusState var focusedField: String?

        var body: some View {
            NumberTextField("Hello", text: $value, focusedField: $focusedField, equals: "hello")
        }
    }

    return Preview().padding()
}
