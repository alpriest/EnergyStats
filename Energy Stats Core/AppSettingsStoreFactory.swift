//
//  AppSettingsPublisherFactory.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/12/2023.
//

import Combine
import Foundation

public typealias CurrentAppSettings = CurrentValueSubject<AppSettings, Never>

public enum AppSettingsStoreFactory {
    public static var shared: AppSettingsStore?

    public static func make() -> AppSettingsStore {
        if let shared = AppSettingsStoreFactory.shared {
            return shared
        } else {
            let value = AppSettingsStore()
            AppSettingsStoreFactory.shared = value
            return value
        }
    }

    public static func update(from config: ConfigManaging) {
        AppSettingsStoreFactory.shared?.update(AppSettings.make(from: config))
    }
}

public final class AppSettingsStore {
    private var subject = CurrentValueSubject<AppSettings, Never>(.mock())
    
    public var currentValue: AppSettings {
        subject.value
    }
    
    public var publisher: AnyPublisher<AppSettings, Never> { subject.eraseToAnyPublisher() }
    
    public func update(_ appSettings: AppSettings) {
        subject.send(appSettings)
    }
}
