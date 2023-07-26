//
//  NumberTextField.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct NumberTextField: View {
    let title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text, perform: { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    text = filtered
                }
                if Int(text) ?? 0 < 0 {
                    text = "0"
                }
                if Int(text) ?? 0 > 100 {
                    text = "100"
                }
            })

    }
}

struct NumberTextField_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .padding()
    }

    struct Preview: View {
        @State var value = "12"

        var body: some View {
            NumberTextField("Hello", text: $value)
        }
    }
}
