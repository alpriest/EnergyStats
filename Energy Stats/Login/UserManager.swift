//
//  UserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Foundation

class UserManager: ObservableObject {
    enum State: Equatable {
        case idle
        case busy
        case error(String)
    }

    private let networking: Networking
    private let configManager: ConfigManager
    private let store: KeychainStore
    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var state = State.idle
    @MainActor @Published var isLoggedIn: Bool = false

    init(networking: Networking, store: KeychainStore, configManager: ConfigManager) {
        self.networking = networking
        self.store = store
        self.configManager = configManager

        self.store.$hasCredentials
            .sink { hasCredentials in
                Task { await MainActor.run { [weak self] in
                    self?.isLoggedIn = hasCredentials
                }}
            }.store(in: &cancellables)
    }

    func getUsername() -> String? {
        store.getUsername()
    }

    @MainActor
    func login(username: String, password: String) async {
        if username == "demo", password == "user" {
            configManager.isDemoUser = true
            configManager.hasBattery = true
            do { try store.store(username: "demo", hashedPassword: "user") } catch {
                state = .error("Could not login as demo user")
            }
            return
        }

        do {
            state = .busy

            guard let hashedPassword = password.md5() else { throw NSError(domain: "md5", code: 0) }

            try await networking.verifyCredentials(username: username, hashedPassword: hashedPassword)
            try store.store(username: username, hashedPassword: hashedPassword, updateHasCredentials: false)
            try await configManager.findDevice()
            store.updateHasCredentials()
        } catch let error as NetworkError {
            logout()

            switch error {
            case .badCredentials:
                self.state = .error("Wrong credentials, try again")
            default:
                print(error)
                self.state = .error("Could not login. Check your internet connection")
            }
        } catch {
            await MainActor.run {
                self.state = .error("Could not login. Check your internet connection \(error)")
            }
        }
    }

    @MainActor
    func logout() {
        store.logout()
        configManager.logout()
        state = .idle
    }
}

struct AppTheme {
    var showColouredLines: Bool
    var showBatteryTemperature: Bool
    var showSunnyBackground: Bool
    var decimalPlaces: Int
}

typealias LatestAppTheme = CurrentValueSubject<AppTheme, Never>

protocol ConfigManaging {
    func findDevice() async throws
    func logout()
    var minSOC: Double { get }
    var batteryCapacity: String { get set }
    var batteryCapacityKW: Int { get }
    var deviceID: String? { get }
    var deviceSN: String? { get }
    var hasBattery: Bool { get set }
    var hasPV: Bool { get }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var refreshFrequency: RefreshFrequency { get set }
    var appTheme: LatestAppTheme { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: DeviceList? { get set }
}

class ConfigManager: ConfigManaging {
    private let networking: Networking
    private var config: Config
    var appTheme: CurrentValueSubject<AppTheme, Never>

    struct NoDeviceFoundError: Error {}

    init(networking: Networking, config: Config) {
        self.networking = networking
        self.config = config
        appTheme = CurrentValueSubject(
            AppTheme(
                showColouredLines: config.showColouredLines,
                showBatteryTemperature: config.showBatteryTemperature,
                showSunnyBackground: config.showSunnyBackground,
                decimalPlaces: config.decimalPlaces
            )
        )
    }

    func findDevice() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard let device = deviceList.devices.first else {
            throw NoDeviceFoundError()
        }

        config.deviceSN = device.deviceSN
        config.deviceID = device.deviceID
        config.hasBattery = device.hasBattery
        config.hasPV = device.hasPV

        if device.hasBattery {
            let battery = try await networking.fetchBattery()
            let batterySettings = try await networking.fetchBatterySettings()
            config.batteryCapacity = String(Int(battery.residual / (Double(battery.soc) / 100.0)))
            config.minSOC = String(Double(batterySettings.minSoc) / 100.0)
        }
    }

    func logout() {
        config.deviceID = nil
        config.deviceSN = nil
        config.hasPV = false
        config.hasBattery = false
        config.isDemoUser = false
    }

    var minSOC: Double { Double(config.minSOC ?? "0.2") ?? 0.0 }

    var batteryCapacity: String {
        get { config.batteryCapacity ?? "2600" }
        set {
            config.batteryCapacity = newValue
        }
    }

    var batteryCapacityKW: Int {
        Int(batteryCapacity) ?? 0
    }

    var deviceID: String? { config.deviceID }

    var deviceSN: String? { config.deviceSN }

    var hasBattery: Bool {
        get { config.hasBattery }
        set { config.hasBattery = newValue }
    }

    var hasPV: Bool { config.hasPV }

    var isDemoUser: Bool {
        get { config.isDemoUser }
        set {
            config.isDemoUser = newValue
            appTheme.send(
                AppTheme(
                    showColouredLines: config.showColouredLines,
                    showBatteryTemperature: config.showBatteryTemperature,
                    showSunnyBackground: showSunnyBackground,
                    decimalPlaces: decimalPlaces
                )
            )
        }
    }

    var showColouredLines: Bool {
        get { config.showColouredLines }
        set {
            config.showColouredLines = newValue
            appTheme.send(
                AppTheme(
                    showColouredLines: config.showColouredLines,
                    showBatteryTemperature: config.showBatteryTemperature,
                    showSunnyBackground: showSunnyBackground,
                    decimalPlaces: decimalPlaces
                )
            )
        }
    }

    var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appTheme.send(
                AppTheme(
                    showColouredLines: config.showColouredLines,
                    showBatteryTemperature: config.showBatteryTemperature,
                    showSunnyBackground: showSunnyBackground,
                    decimalPlaces: decimalPlaces
                )
            )
        }
    }

    var refreshFrequency: RefreshFrequency {
        get { RefreshFrequency(rawValue: config.refreshFrequency) ?? .AUTO }
        set { config.refreshFrequency = newValue.rawValue }
    }

    var showSunnyBackground: Bool {
        get { config.showSunnyBackground }
        set {
            config.showSunnyBackground = newValue
            appTheme.send(
                AppTheme(
                    showColouredLines: config.showColouredLines,
                    showBatteryTemperature: config.showBatteryTemperature,
                    showSunnyBackground: showSunnyBackground,
                    decimalPlaces: decimalPlaces
                )
            )
        }
    }

    var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appTheme.send(
                AppTheme(
                    showColouredLines: config.showColouredLines,
                    showBatteryTemperature: config.showBatteryTemperature,
                    showSunnyBackground: showSunnyBackground,
                    decimalPlaces: decimalPlaces
                )
            )
        }
    }

    var devices: DeviceList? {
        get {
            guard let deviceListData = config.devices else { return nil }
            do {
                return try JSONDecoder().decode(DeviceList.self, from: deviceListData)
            } catch {
                return nil
            }
        }
        set {
            if let newValue {
                do {
                    config.devices = try JSONEncoder().encode(newValue)
                } catch {
                    print("AWP", "Failed to encode device list 💥")
                }
            } else {
                config.devices = nil
            }
        }
    }
}
