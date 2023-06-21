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
        app.launch()

        if app.buttons["try_demo"].exists {
            app.buttons["try_demo"].tap()
        }

        app.buttons["power_flow_tab"].tap()

        snapshot("01_power_flow_tab")

        app.buttons["stats_tab"].tap()
        app.buttons["stats_datepicker"].tap()
        app.buttons["Month"].tap()

        snapshot("02_stats_tab")

        app.buttons["parameters_tab"].tap()

        snapshot("03_graph_tab")

        app.buttons["variable_chooser"].tap()

        snapshot("04_choose_variable")

        app.buttons["cancel"].tap()

        app.buttons["settings_tab"].tap()

        snapshot("05_settings_tab")
    }
}
