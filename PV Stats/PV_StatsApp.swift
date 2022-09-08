//
//  PV_StatsApp.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

@main
struct PV_StatsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(networking: Network())
        }
    }
}
