//
//  XCTestCase+OHHTTPStubs.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

extension XCTestCase {
    func stubHTTPResponse(with filename: String) {
        stubHTTPResponses(with: [filename])
    }

    func stubHTTPResponses(with filenames: [String]) {
        var callCount = 0

        stub(condition: isHost("www.foxesscloud.com")) { _ in
            callCount += 1

            let filename: String
            if let result = filenames[safe: callCount - 1] {
                filename = result
            } else {
                filename = filenames.last!
            }

            let stubPath = OHPathForFile(filename, type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }
    }

    func stubOffline() {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return HTTPStubsResponse(error: notConnectedError)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices ~= index else { return nil }
        return self[index]
    }
}
