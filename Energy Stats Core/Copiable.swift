//
//  Copiable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/11/2025.
//

public protocol Copiable {
    func copy(_ updates: (inout Self) -> Void) -> Self
    func create(copying previous: Self) -> Self
}

public extension Copiable {
    func copy(_ updates: (inout Self) -> Void) -> Self {
        var newValue = create(copying: self)
        updates(&newValue)
        return newValue
    }
}
