//
//  AppDelegate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/06/2024.
//

import BackgroundTasks
import Energy_Stats_Core
import Foundation
import OSLog
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.alpriest.EnergyStats.refresh", using: nil) { task in
            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        let config = UserDefaultsConfig()

        Logger().log("AWP Refresh started \(String(describing: config.selectedDeviceSN))")

        if let selectedDeviceSN = config.selectedDeviceSN {
            let keychainStore = KeychainStore()
            let network = NetworkService.standard(keychainStore: keychainStore,
                                                  isDemoUser: { config.isDemoUser },
                                                  dataCeiling: { config.dataCeiling })

            Task {
                try await network.setScheduleFlag(deviceSN: selectedDeviceSN, enable: false)
                task.setTaskCompleted(success: true)
            }
        }
    }
}

enum Scheduler {
    static func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.alpriest.EnergyStats.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)

        Logger().log("AWP Refresh scheduled for \(String(describing: request.earliestBeginDate))")

        do {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
