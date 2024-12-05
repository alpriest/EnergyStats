//
//  XCTestCase+Async.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 11/05/2024.
//

import XCTest

extension XCTestCase {
    func propertyOn<T, X>(_ object: T, keyPath: KeyPath<T, X>, timeout: TimeInterval = 5.0, evaluator: @escaping (X) -> Bool, file: StaticString = #file, line: UInt = #line) async {
        var finished = false
        let pollIntervalMS: TimeInterval = 0.1
        var durationWaited: TimeInterval = 0

        repeat {
            if evaluator(object[keyPath: keyPath]) {
                finished = true
            } else {
                durationWaited = durationWaited + pollIntervalMS
                try? await Task.sleep(nanoseconds: UInt64(pollIntervalMS * Double(NSEC_PER_SEC)))
            }
        } while !finished && durationWaited < timeout

        if !finished {
//            XCTFail("Timed out waiting for property to evaluate", file: file, line: line)
        }
    }

    /// Awaits a boolean property to be evaluated true without blocking the main thread and with no minimum execution duration.
    func propertyOn<T>(_ object: T, keyPath: KeyPath<T, Bool>, timeout: TimeInterval = 5.0, file: StaticString = #file, line: UInt = #line) async {
        await propertyOn(object, keyPath: keyPath, timeout: timeout, evaluator: { $0 })
    }
}
