//
//  SubLabelledView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import SwiftUI

public struct SubLabelledView: View {
    private let value: String
    private let label: String
    private let alignment: HorizontalAlignment

    public init(value: String, label: String, alignment: HorizontalAlignment) {
        self.value = value
        self.label = label
        self.alignment = alignment
    }

    public init(
        value: Double?,
        label: String,
        appSettings: AppSettings,
        alignment: HorizontalAlignment,
        decimalPlaceOverride: Int
    ) {
        self.value = value?.roundedToString(decimalPlaces: decimalPlaceOverride) ?? ""
        self.label = label
        self.alignment = alignment
    }

    public var body: some View {
        VStack(alignment: alignment) {
            Text(value)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 8.0))
        }
    }
}

