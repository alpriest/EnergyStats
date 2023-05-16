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

        snapshot("power_flow_tab")

        app.buttons["settings_tab"].tap()

        snapshot("settings_tab")

        app.buttons["graph_tab"].tap()

        snapshot("graph_tab")

        app.buttons["variable_chooser"].tap()

        snapshot("choose_variable")
    }
}
