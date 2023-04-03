//
//  CountdownTimer.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

public class CountdownTimer {
    private var ticksRemaining: Int = 0
    @MainActor private var timer: Timer?

    public init() {}

    deinit {
        timer?.invalidate()
    }

    @MainActor
    public func start(totalTicks: Int, onTick: @escaping (Int) -> Void, onCompletion: @escaping () -> Void) {
        stop()
        ticksRemaining = totalTicks
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.ticksRemaining -= 1

            onTick(self.ticksRemaining)

            if self.ticksRemaining <= 0 {
                timer.invalidate()
                onCompletion()
                return
            }
        }
    }

    @MainActor
    public func stop() {
        timer?.invalidate()
        timer = nil
        ticksRemaining = 0
    }
}
