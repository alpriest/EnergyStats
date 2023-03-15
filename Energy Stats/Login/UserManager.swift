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
            try await configManager.findDevices()
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
    var showBatteryEstimate: Bool

    func update(
        showColouredLines: Bool? = nil,
        showBatteryTemperature: Bool? = nil,
        showSunnyBackground: Bool? = nil,
        decimalPlaces: Int? = nil,
        showBatteryEstimate: Bool? = nil
    ) -> AppTheme {
        AppTheme(
            showColouredLines: showColouredLines ?? self.showColouredLines,
            showBatteryTemperature: showBatteryTemperature ?? self.showBatteryTemperature,
            showSunnyBackground: showSunnyBackground ?? self.showSunnyBackground,
            decimalPlaces: decimalPlaces ?? self.decimalPlaces,
            showBatteryEstimate: showBatteryEstimate ?? self.showBatteryEstimate
        )
    }
}

typealias LatestAppTheme = CurrentValueSubject<AppTheme, Never>

protocol ConfigManaging {
    func findDevices() async throws
    func logout()
    var minSOC: Double { get }
    var batteryCapacity: String { get set }
    var batteryCapacityKW: Int { get }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var refreshFrequency: RefreshFrequency { get set }
    var appTheme: LatestAppTheme { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var currentDevice: Device? { get }
    var selectedDeviceID: String? { get set }
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
                decimalPlaces: config.decimalPlaces,
                showBatteryEstimate: config.showBatteryEstimate
            )
        )
    }

    func findDevices() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard deviceList.devices.count > 0 else {
            throw NoDeviceFoundError()
        }

        devices = try await deviceList.devices.asyncMap { device in
            let batteryCapacity: String?
            let minSOC: String?

            if device.hasBattery {
                let battery = try await networking.fetchBattery(deviceID: device.deviceID)
                let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)
                batteryCapacity = String(Int(battery.residual / (Double(battery.soc) / 100.0)))
                minSOC = String(Double(batterySettings.minSoc) / 100.0)
            } else {
                batteryCapacity = nil
                minSOC = nil
            }

            return Device(
                plantName: device.plantName,
                deviceID: device.deviceID,
                deviceSN: device.deviceSN,
                hasPV: device.hasPV,
                battery: device.hasBattery ? Device.Battery(capacity: batteryCapacity, minSOC: minSOC) : nil
            )
        }
        selectedDeviceID = devices?.first?.deviceID
    }

    func logout() {
        config.selectedDeviceID = nil
        config.devices = nil
        config.isDemoUser = false
    }

    var minSOC: Double { Double(currentDevice?.battery?.minSOC ?? "0.2") ?? 0.0 }

    var batteryCapacity: String {
        get { currentDevice?.battery?.capacity ?? "2600" }
        set {
            devices = devices?.map {
                if $0.deviceID == currentDevice?.deviceID, let battery = $0.battery {
                    return Device(plantName: $0.plantName, deviceID: $0.deviceID, deviceSN: $0.deviceSN, hasPV: $0.hasPV, battery: Device.Battery(capacity: newValue, minSOC: battery.minSOC))
                } else {
                    return $0
                }
            }
        }
    }

    var batteryCapacityKW: Int {
        Int(currentDevice?.battery?.capacity ?? "0") ?? 0
    }

    var currentDevice: Device? {
        devices?.first(where: { $0.deviceID == selectedDeviceID }) ?? devices?.first
    }

    var selectedDeviceID: String? {
        get { config.selectedDeviceID }
        set { config.selectedDeviceID = newValue }
    }

    var isDemoUser: Bool {
        get { config.isDemoUser }
        set {
            config.isDemoUser = newValue
        }
    }

    var showColouredLines: Bool {
        get { config.showColouredLines }
        set {
            config.showColouredLines = newValue
            appTheme.send(appTheme.value.update(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appTheme.send(appTheme.value.update(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appTheme.send(appTheme.value.update(
                showBatteryEstimate: config.showBatteryEstimate
            ))
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
            appTheme.send(appTheme.value.update(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appTheme.send(appTheme.value.update(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    var devices: [Device]? {
        get {
            guard let deviceListData = config.devices else { return nil }
            do {
                return try JSONDecoder().decode([Device].self, from: deviceListData)
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
