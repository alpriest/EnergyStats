//
//  ViewDataProviding.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/11/2025.
//

import Energy_Stats_Core

protocol ViewDataProviding: AnyObject {
    associatedtype ViewData: Copiable

    var viewData: ViewData { get set }
    var originalValue: ViewData? { get set }
    var isDirty: Bool { get set }

    func resetDirtyState()
}

extension ViewDataProviding {
    func resetDirtyState() {
        self.originalValue = viewData
        self.isDirty = false
    }
}
