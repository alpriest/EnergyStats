//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import XCTest
@testable import Energy_Stats
import Combine

@MainActor
final class UserManagerTests: XCTestCase {
    func test_IsLoggedIn_SetsOnInitialisation() {
        var expectation: XCTestExpectation? = self.expectation(description: #function)
        let keychainStore = MockKeychainStore()
        keychainStore.hasCredentials = true

        let sut = UserManager(networking: MockNetworking(), store: keychainStore)

        sut.$isLoggedIn
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                if value {
                    expectation?.fulfill()
                    expectation = nil
                }
            }))

        wait(for: [expectation!], timeout: 1.0)
        XCTAssertTrue(sut.isLoggedIn)
    }
}
