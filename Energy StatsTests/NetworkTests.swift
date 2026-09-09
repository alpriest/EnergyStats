//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import OHHTTPStubs
import Testing

@Suite(.serialized)
final class NetworkTests {
    private let sut: FoxAPIServicing

    init() {
        sut = FoxAPIService(apiTokenProvider: { "" }, urlSession: URLSession.shared, tracer: nil)
    }

    deinit {
        HTTPStubs.removeAllStubs()
    }

    @Test func `Fetch report returns data on success`() async throws {
        stubHTTPResponse(with: .reportSuccess)

        let report = try await sut.openapi_fetchReport(
            deviceSN: "any",
            variables: [
                .feedIn,
                .gridConsumption,
                .generation,
                .chargeEnergyToTal,
                .dischargeEnergyToTal
            ],
            queryDate: QueryDate.any(),
            reportType: .day
        )

        #expect(report.count == 5)
    }

    @Test func `Fetch real data returns data on success`() async throws {
        stubHTTPResponse(with: .realSuccess)

        let raw = try await sut.openapi_fetchRealData(deviceSN: "DEVICESN", variables: [
            Variable(name: "feedinPower", variable: "feedinPower", unit: "kWH"),
            Variable(name: "gridConsumptionPower", variable: "gridConsumptionPower", unit: "kWH"),
            Variable(name: "batChargePower", variable: "batChargePower", unit: "kWH"),
            Variable(name: "batDischargePower", variable: "batDischargePower", unit: "kWH"),
            Variable(name: "generationPower", variable: "generationPower", unit: "kWH"),
            Variable(name: "ResidualEnergy", variable: "ResidualEnergy", unit: "kWH"),
            Variable(name: "batTemperature", variable: "batTemperature", unit: "℃"),
        ].map { $0.variable })

        #expect(raw.datas.count == 7)
    }

    @Test func `Fetch device list returns data on success`() async throws {
        stubHTTPResponse(with: .deviceListSuccess)

        let devices = try await sut.openapi_fetchDeviceList()

        #expect(devices.first?.deviceSN == "DEVICESN")
    }

    @Test func `Fetch report throws when offline`() async {
        stubOffline()

        await #expect(throws: NetworkError.offline) {
            _ = try await sut.openapi_fetchReport(deviceSN: "!", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        }
    }

    @Test func `Fetch report returns try later`() async {
        stubHTTPResponse(with: .tryLaterFailure)

        await #expect(throws: NetworkError.tryLater) {
            _ = try await sut.openapi_fetchReport(deviceSN: "1", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        }
    }
}

extension QueryDate {
    static func any() -> QueryDate {
        .init(year: 2022, month: 11, day: 22)
    }
}
