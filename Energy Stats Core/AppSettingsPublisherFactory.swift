//
//  AppSettingsPublisherFactory.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/12/2023.
//

import Combine
import Foundation

public typealias CurrentAppSettings = CurrentValueSubject<AppSettings, Never>

public enum AppSettingsPublisherFactory {
    public static var shared: CurrentAppSettings?

    public static func make() -> CurrentAppSettings {
        if let shared = AppSettingsPublisherFactory.shared {
            return shared
        } else {
            let value: CurrentAppSettings = CurrentValueSubject(AppSettings.mock())
            AppSettingsPublisherFactory.shared = value
            return value
        }
    }

    public static func update(from config: ConfigManaging) {
        AppSettingsPublisherFactory.shared?.value = AppSettings.make(from: config)
    }
}
