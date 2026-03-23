//
//  Dictionary+Keys.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/03/2026.
//

import Foundation

public extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        [T: Value](
            uniqueKeysWithValues: self.map { (transform($0.key), $0.value) }
        )
    }
}
