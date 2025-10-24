//
//  SingleSelectView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import SwiftUI

public struct SelectableItem: Identifiable, Equatable, Hashable {
    public let item: WorkMode
    public var isSelected: Bool
    public var id: String { item.title }

    public init(_ item: WorkMode, isSelected: Bool = false) {
        self.item = item
        self.isSelected = isSelected
    }

    public mutating func setSelected(_ selected: Bool) {
        isSelected = selected
    }
}
