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

        snapshot("1_power_flow_tab")

        app.buttons["stats_tab"].tap()
        app.buttons["stats_datepicker"].tap()
        app.buttons["Month"].tap()

        snapshot("2_stats_tab")

        app.buttons["parameters_tab"].tap()

        snapshot("3_graph_tab")

        app.buttons["variable_chooser"].tap()

        snapshot("4_choose_variable")

        app.buttons["cancel"].tap()

        app.buttons["settings_tab"].tap()

        snapshot("5_settings_tab")
    }
}
