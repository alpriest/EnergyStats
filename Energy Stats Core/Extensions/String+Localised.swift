//
//  String+Localised.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2025.
//

import SwiftUI

public extension String {
    func localised() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}
