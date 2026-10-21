//
//  Array+EnergyPriceRate.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 21/10/2026.
//

import Foundation

public extension Array where Element == EnergyPriceRate {
    func price(for date: Date) -> Double {
        let day = Calendar.current.startOfDay(for: date)
        return sortedForCalculation().first(where: {
            guard let effectiveFrom = $0.effectiveFrom else { return true }
            return Calendar.current.startOfDay(for: effectiveFrom) <= day
        })?.price ?? 0
    }

    func weightedPrice(for interval: DateInterval) -> Double {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: interval.start)
        let end = calendar.startOfDay(for: interval.end)
        let totalDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        guard totalDays > 0 else { return price(for: start) }

        let rates = sortedForCalculation()
        var weightedTotal = 0.0

        for (index, rate) in rates.enumerated() {
            let rateStart = rate.effectiveFrom.map { calendar.startOfDay(for: $0) } ?? .distantPast
            let rateEnd = rates.prefix(index).compactMap(\.effectiveFrom).map { calendar.startOfDay(for: $0) }.max() ?? .distantFuture
            let overlapStart = Swift.max(start, rateStart)
            let overlapEnd = Swift.min(end, rateEnd)
            guard overlapStart < overlapEnd else { continue }

            let days = calendar.dateComponents([.day], from: overlapStart, to: overlapEnd).day ?? 0
            weightedTotal += rate.price * Double(days)
        }

        return weightedTotal / Double(totalDays)
    }

    private func sortedForCalculation() -> [EnergyPriceRate] {
        sorted { lhs, rhs in
            switch (lhs.effectiveFrom, rhs.effectiveFrom) {
            case let (left?, right?): return left > right
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

extension Array where Element == EnergyPriceRate {
    public func sortedForDisplay() -> [EnergyPriceRate] {
        sorted { lhs, rhs in
            switch (lhs.effectiveFrom, rhs.effectiveFrom) {
            case let (left?, right?): return left > right
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return false
            }
        }
    }
}
