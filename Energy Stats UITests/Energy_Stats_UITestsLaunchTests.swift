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

    func test_takeScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        if app.buttons["try_demo"].exists {
            app.buttons["try_demo"].tap()
        }

        app.buttons["power_flow_tab"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "power_flow"
        attachment.lifetime = .keepAlways
        add(attachment)

        app.buttons["settings_tab"].tap()

        let attachment2 = XCTAttachment(screenshot: app.screenshot())
        attachment2.name = "settings_tab"
        attachment2.lifetime = .keepAlways
        add(attachment2)

        app.buttons["graph_tab"].tap()

        let attachment3 = XCTAttachment(screenshot: app.screenshot())
        attachment3.name = "graph_tab"
        attachment3.lifetime = .keepAlways
        add(attachment3)
    }
}
