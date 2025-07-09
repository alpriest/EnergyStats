//
//  SingleSelectView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import SwiftUI

public protocol Describable {
    var title: String { get }
}

public typealias Selectable = Describable & Hashable

public struct SelectableItem<T: Selectable>: Identifiable, Equatable, Hashable {
    public let item: T
    public var isSelected: Bool
    public var id: String { item.title }

    public init(_ item: T, isSelected: Bool = false) {
        self.item = item
        self.isSelected = isSelected
    }

    public mutating func setSelected(_ selected: Bool) {
        isSelected = selected
    }
}
