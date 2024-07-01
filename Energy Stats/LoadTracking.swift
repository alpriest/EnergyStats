//
//  LoadTracking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/07/2024.
//

import Foundation

protocol LoadTracking<T>: AnyObject {
    associatedtype T

    var lastLoadState: LastLoadState<T>? { get set }
    func requiresLoad() -> Bool
}

struct LastLoadState<T> {
    var lastLoadTime: Date
    var loadState: T
}
