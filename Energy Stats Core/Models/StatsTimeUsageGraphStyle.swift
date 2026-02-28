//
//  TimeGraphStyle.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 28/02/2026.
//

import Foundation

public enum StatsTimeUsageGraphStyle: Int, CaseIterable, RawRepresentable {
    case bar = 0
    case line = 1
    case off = 2

    public var isOn: Bool {
        switch self {
        case .off:
            return false
        case .line, .bar:
            return true
        }
    }

    public var isLine: Bool {
        switch self {
        case .line:
            return true
        case .off, .bar:
            return false
        }
    }

    public var isBar: Bool {
        switch self {
        case .bar:
            return true
        case .off, .line:
            return false
        }
    }

    // TODO: localize
    public var title: String {
        switch self {
        case .off:
            return "Hidden"
        case .line:
            return "Line"
        case .bar:
            return "Bar"
        }
    }
}
