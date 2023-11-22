//
//  Array+Any.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

public extension Array {
    func any() -> Bool {
        !isEmpty
    }

    func anySatisfy(_ predicate: (Element) -> Bool) -> Bool {
        for element in self {
            if predicate(element) {
                return true
            }
        }
        return false
    }
}
