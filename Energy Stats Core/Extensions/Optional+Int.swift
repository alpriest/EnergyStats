//
//  Optional+Int.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 12/12/2023.
//

import Foundation

public extension Int {
    init?(_ value: String?) {
        guard let value else { return nil }

        self.init(value)
    }
}
