//
//  ContentViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

@MainActor class ContentViewModel: ObservableObject {
    private let network: Networking
    @Published private(set) var report: ReportViewModel?
    @Published private(set) var battery: BatteryViewModel?
    @Published private(set) var lastUpdated: String = Date().formatted()

    init(_ network: Networking) {
        self.network = network
    }
    
    func fetch() async throws {
        let (report, battery) = try await network.fetch()
        self.report = ReportViewModel(from: report)
        self.battery = BatteryViewModel(from: battery)
        self.lastUpdated = Date().formatted()
    }
}
