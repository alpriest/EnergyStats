//
//  NumberTextField.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct NumberTextField: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding var text: String

    init(_ title: String, text: Binding<String>, range: ClosedRange<Int>) {
        self.title = title
        self._text = text
        self.range = range
    }

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text, perform: { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    text = filtered
                }
                if Int(text) ?? 0 < range.lowerBound {
                    text = String(describing: range.lowerBound)
                }
                if Int(text) ?? 0 > range.upperBound {
                    text = String(describing: range.upperBound)
                }
            })
    }
}

#Preview {
    struct Preview: View {
        @State var value = "12"

        var body: some View {
            NumberTextField("Hello", text: $value, range: 1 ... 100)
        }
    }

    return Preview().padding()
}
