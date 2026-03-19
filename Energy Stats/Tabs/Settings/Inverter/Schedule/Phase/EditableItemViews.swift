//
//  EditableItemViews.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2026.
//

import Energy_Stats_Core
import SwiftUI

struct EditableItemView<Field: Hashable>: View {
    let title: String
    let field: Field
    let numberTitle: String
    let numberText: Binding<String>
    let unit: String
    let error: LocalizedStringKey?
    let description: LocalizedStringKey?
    let focusedField: FocusState<Field?>.Binding

    var body: some View {
        HStack {
            Text(title)
            OptionalView(description) {
                InfoButtonView(message: $0)
            }
            Spacer()
            NumberTextField(numberTitle, text: numberText, focusedField: focusedField, equals: field)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
            Text(unit)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField.wrappedValue = field
        }
    }
}
