//
//  Energy_Stats_UITestsLaunchTests.swift
//  Energy Stats UITests
//
//  Created by Alistair Priest on 07/03/2023.
//

import XCTest

final class Energy_Stats_UITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_takeScreenshots() async throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["screenshots"]
        app.launch()

        if app.buttons["try_demo"].exists {
            app.buttons["try_demo"].tap()
        }

        app.buttons["power_flow_tab"].tap()

        snapshot("01_power_flow_tab")

        app.buttons["stats_tab"].tap()
        app.buttons["stats_datepicker"].tap()
        app.buttons["month"].tap()

        snapshot("02_stats_tab")

        app.buttons["parameters_tab"].tap()
        snapshot("03_graph_tab")

        app.buttons["variable_chooser"].tap()
        snapshot("04_choose_variable")

        app.buttons["cancel"].tap()

        app.buttons["settings_tab"].tap()
        snapshot("05_settings_tab")

        app.buttons["battery"].tap()
        snapshot("06_battery_settings")

        app.buttons["minimum charge levels"].tap()
        snapshot("07_battery_charge_levels")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["charge schedule"].tap()
        snapshot("08_battery_charge_times")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["financials"].tap()
        app.switches["toggle_financial_summary"].tap()
        snapshot("09_financial_summary")
    }
}
