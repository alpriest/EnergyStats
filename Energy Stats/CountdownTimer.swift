//
//  CountdownTimer.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

class CountdownTimer: ObservableObject {
    private var ticksRemaining: Int = 0
    private var timer: Timer?

    deinit {
        timer?.invalidate()
    }

    func start(totalTicks: Int, onTick: @escaping (Int) -> Void, onCompletion: @escaping () -> Void) {
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

    func stop() {
        timer?.invalidate()
        ticksRemaining = 0
    }
}
