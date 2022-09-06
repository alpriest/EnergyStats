//
//  ContentViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

class ContentViewModel: ObservableObject {
    private let network: Networking
    private var timer: Timer?
    @MainActor @Published private(set) var report: ReportViewModel?
    @MainActor @Published private(set) var battery: BatteryViewModel?
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    
    init(_ network: Networking) {
        self.network = network
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task { [weak self] in
                guard let self = self else { return }
                
                let report = ReportViewModel(from: try await self.network.fetchReport())
                let battery = BatteryViewModel(from: try await self.network.fetchBattery())
                let lastUpdated = Date().small()
                
                await self.update(report, battery, lastUpdated)
            }
        }
        timer?.fire()
    }
    
    @MainActor
    private func update(_ report: ReportViewModel, _ battery: BatteryViewModel, _ lastUpdated: String) {
        self.report = report
        self.battery = battery
        self.lastUpdated = lastUpdated
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
