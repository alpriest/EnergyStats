//
//  SettingItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/05/2025.
//

import Energy_Stats_Core
import SwiftUI

struct SettingItemView: View {
    @State private var isValid: Bool = false
    let name: String
    let item: SettingItem
    let onChange: (String) -> Void

    init(name: String, item: SettingItem, onChange: @escaping (String) -> Void) {
        self.name = name
        self.item = item
        self.onChange = onChange

        isValid = validate(item.value)
    }

    var body: some View {
        let textBinding = Binding<String>(
            get: { self.item.value },
            set: { newValue in
                isValid = validate(newValue)
                if isValid {
                    onChange(newValue)
                }
            }
        )

        HStack {
            Text(name)
            Spacer()
            Group {
                NumberTextField(name, text: textBinding)
                    .multilineTextAlignment(.trailing)
                Text(item.unit)
            }
            .foregroundStyle(textColor)
        }
    }

    private func validate(_ newValue: String) -> Bool {
        guard let doubleValue = Double(newValue) else { return false }
        return item.range.min <= doubleValue &&
            doubleValue <= item.range.max
    }

    var textColor: Color {
        isValid ? Color.textNotFlowing : Color.linesNegative
    }
}

#Preview {
    VStack {
        SettingItemView(
            name: "Import Limit",
            item: SettingItem(
                precision: 0.001,
                range: SettingItem.Range(min: 0.0, max: 100000.0),
                unit: "kW",
                value: "99900.0"
            ),
            onChange: { _ in }
        )
    }
}
