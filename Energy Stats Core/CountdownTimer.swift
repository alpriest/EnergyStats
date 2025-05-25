//
//  CountdownTimer.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

public class CountdownTimer {
    private var task: Task<Void, Never>?
    private var ticksRemaining: Int = 0

    public init() {}

    deinit {
        task = nil
    }

    public func start(totalTicks: Int, onTick: @escaping (Int) -> Void, onCompletion: @escaping () -> Void) {
        stop()
        ticksRemaining = totalTicks
        task = Task {
            while ticksRemaining > 0 {
                if Task.isCancelled {
                    return
                }

                try? await Task.sleep(for: .seconds(1))
                ticksRemaining -= 1
                onTick(ticksRemaining)

                if ticksRemaining <= 0 {
                    onCompletion()
                }
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
        ticksRemaining = 0
    }

    public var isTicking: Bool {
        ticksRemaining > 0 && task != nil
    }
}
