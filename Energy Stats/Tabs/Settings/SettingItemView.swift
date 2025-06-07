//
//  SettingItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/05/2025.
//

import Energy_Stats_Core
import SwiftUI

struct SettingItemView: View {
    let name: String
    let item: SettingItem
    let onChange: (String) -> Void

    init(name: String, item: SettingItem, onChange: @escaping (String) -> Void) {
        self.name = name
        self.item = item
        self.onChange = onChange
    }

    var body: some View {
        let textBinding = Binding<String>(
            get: { self.item.value },
            set: { onChange($0) }
        )

        HStack(spacing: 0) {
            Text(name)
            Spacer()
            HStack {
                NumberTextField("", text: textBinding)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                Text(item.unit)
                    .frame(width: 30, alignment: .leading)
            }
        }
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
