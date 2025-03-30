//
//  CurrentStatusCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Combine
import Foundation

public extension Array where Element == OpenQueryResponse.Data {
    func currentDouble(for key: String) -> Double {
        current(for: key)?.value ?? 0.0
    }

    func currentString(for key: String) -> String? {
        current(for: key)?.stringValue
    }

    func current(for key: String) -> OpenQueryResponse.Data? {
        first(where: { $0.variable.lowercased() == key.lowercased() })
    }

    func SoC() -> Double {
        current(for: "SoC")?.value ?? current(for: "SoC_1")?.value ?? 0.0
    }
}

public protocol CurrentStatusCalculatorConfig {
    var appSettingsPublisher: LatestAppSettingsPublisher { get }
    var shouldInvertCT2: Bool { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var powerFlowStrings: PowerFlowStringsSettings { get set }
    var shouldCombineCT2WithLoadsPower: Bool { get set }
}

public struct CurrentValues {
    public let solarPower: Double
    public let solarStringsPower: [StringPower]
    public let grid: Double
    public let homeConsumption: Double
    public let temperatures: InverterTemperatures?
    public let ct2: Double
}

public class CurrentStatusCalculator {
    public var lastUpdate: Date = Date()
    private let currentValuesSubject = CurrentValueSubject<CurrentValues, Never>(CurrentValues(solarPower: 0, solarStringsPower: [], grid: 0, homeConsumption: 0, temperatures: nil, ct2: 0))
    public var currentValuesPublisher: AnyPublisher<CurrentValues, Never> { currentValuesSubject.eraseToAnyPublisher() }
    private let config: CurrentStatusCalculatorConfig
    private let device: Device
    private let response: OpenQueryResponse
    private var cancellables = Set<AnyCancellable>()

    public init(
        device: Device,
        response: OpenQueryResponse,
        config: CurrentStatusCalculatorConfig
    ) {
        self.device = device
        self.response = response
        self.config = config

        config.appSettingsPublisher.sink { [weak self] _ in
            self?.updateCurrentValues()
        }.store(in: &cancellables)

        updateCurrentValues()
    }

    public func currentValues() -> CurrentValues {
        currentValuesSubject.value
    }

    private func updateCurrentValues() {
        let shouldInvertCT2 = config.shouldInvertCT2
        let shouldCombineCT2WithPVPower = config.shouldCombineCT2WithPVPower
        let status = Self.mapCurrentValues(device: device, response: response, config: config)
        let currentGrid = status.feedinPower - status.gridConsumptionPower
        let currentHomeConsumption = Self.calculateLoadPower(status: status, shouldCombineCT2WithLoadsPower: config.shouldCombineCT2WithLoadsPower)
        let currentTemperatures = InverterTemperatures(ambient: status.ambientTemperation, inverter: status.invTemperation)
        self.lastUpdate = status.lastUpdate
        let currentCT2 = shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2
        let currentSolarPower = Self.calculateSolarPower(hasPV: status.hasPV, status: status, shouldInvertCT2: shouldInvertCT2, shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower)
        let currentSolarStringsPower = Self.calculateSolarStringsPower(hasPV: status.hasPV, status: status)

        currentValuesSubject.send(
            CurrentValues(
                solarPower: currentSolarPower,
                solarStringsPower: currentSolarStringsPower,
                grid: currentGrid,
                homeConsumption: currentHomeConsumption,
                temperatures: currentTemperatures,
                ct2: currentCT2
            )
        )
    }

    static func mapCurrentValues(device: Device, response: OpenQueryResponse, config: CurrentStatusCalculatorConfig) -> CurrentRawValues {
        var stringsPvPower: [StringPower] = []
        if config.powerFlowStrings.enabled {
            stringsPvPower = config.powerFlowStrings.makeStringPowers(from: response)
        }

        return CurrentRawValues(
            pvPower: response.datas.currentDouble(for: "pvPower"),
            stringsPvPower: stringsPvPower,
            feedinPower: response.datas.currentDouble(for: "feedinPower"),
            gridConsumptionPower: response.datas.currentDouble(for: "gridConsumptionPower"),
            loadsPower: response.datas.currentDouble(for: "loadsPower"),
            generationPower: response.datas.currentDouble(for: "generationPower"),
            epsPower: response.datas.currentDouble(for: "epsPower"),
            ambientTemperation: response.datas.currentDouble(for: "ambientTemperation"),
            invTemperation: response.datas.currentDouble(for: "invTemperation"),
            meterPower2: response.datas.currentDouble(for: "meterPower2"),
            hasPV: device.hasPV,
            lastUpdate: response.time
        )
    }

    static func calculateLoadPower(status: CurrentRawValues, shouldCombineCT2WithLoadsPower: Bool) -> Double {
        status.gridConsumptionPower + status.generationPower - status.feedinPower + (shouldCombineCT2WithLoadsPower ? abs(status.meterPower2) : 0)
    }

    static func calculateSolarPower(hasPV: Bool, status: CurrentRawValues, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) -> Double {
        let ct2 = (shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2)

        if hasPV {
            return status.pvPower + (shouldCombineCT2WithPVPower ? ct2 : 0.0)
        } else {
            return ct2
        }
    }

    static func calculateSolarStringsPower(hasPV: Bool, status: CurrentRawValues) -> [StringPower] {
        if hasPV {
            return status.stringsPvPower
        } else {
            return []
        }
    }
}

public extension Date {
    func small() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: self)
    }

    func iso8601() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

public extension DateFormatter {
    static func forDebug() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter
    }
}

public struct CurrentRawValues {
    let pvPower: Double
    let stringsPvPower: [StringPower]
    let feedinPower: Double
    let gridConsumptionPower: Double
    let loadsPower: Double
    let generationPower: Double
    let epsPower: Double
    let ambientTemperation: Double
    let invTemperation: Double
    let meterPower2: Double
    let hasPV: Bool
    let lastUpdate: Date

    static func empty() -> CurrentRawValues {
        .init(pvPower: 2, stringsPvPower: [], feedinPower: 0, gridConsumptionPower: 0, loadsPower: 0, generationPower: 0, epsPower: 0, ambientTemperation: 0, invTemperation: 0, meterPower2: 0, hasPV: false, lastUpdate: Date())
    }
}
