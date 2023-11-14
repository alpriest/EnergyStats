//
//  SolarForecastViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2023.
//

import Foundation
import Energy_Stats_Core

class SolarForecastViewModel: ObservableObject {
    @Published var today: [SolcastForecastResponse] = []
    @Published var tomorrow: [SolcastForecastResponse] = []
    let service: SolarForecasting
    @Published var state: LoadState = .inactive

    init(service: SolarForecasting) {
        self.service = service
    }

    func load() {
        guard state == .inactive else { return }

        state = .active("Loading...")

        Task {
            let data = try await service.fetchForecast().forecasts // CACHE
            let today = Date()
            let tomorrow = Date().addingTimeInterval(86400)

            Task { @MainActor in
                self.today = data.filter { $0.period_end.isSame(as: today) }
                self.tomorrow = data.filter { $0.period_end.isSame(as: tomorrow) }
                self.state = .inactive
            }
        }
    }
}
