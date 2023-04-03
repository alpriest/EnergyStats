//
//  Energy_Stats_Watch_AppApp.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 03/04/2023.
//

import SwiftUI

@main
struct Energy_Stats_Watch_App_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(solar: 1.5,
                        grid: 0.5,
                        batteryAvailableCapacity: 0.97,
                        batteryMessage: "Empty in 19 hours")
        }
    }
}
