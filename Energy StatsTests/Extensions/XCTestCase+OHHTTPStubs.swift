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
    func stubHTTPResponse(with filename: FoxEssHTTPResponse) {
        stubHTTPResponses(with: [filename])
    }

    func stubHTTPResponses(with filenames: [FoxEssHTTPResponse]) {
        var callCount = 0

        stub(condition: isHost("www.foxesscloud.com")) { _ in
            callCount += 1

            let filename: FoxEssHTTPResponse
            if let result = filenames[safe: callCount - 1] {
                filename = result
            } else {
                filename = filenames.last!
            }

            let stubPath = OHPathForFile(filename.rawValue, type(of: self))
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

enum FoxEssHTTPResponse: String {
    case deviceListSuccess = "devicelist-success.json"
    case firmwareVersionSuccess = "firmware-version-success.json"
    case variablesSuccess = "variables-success.json"
    case rawSuccess = "raw-success.json"
    case batterySuccess = "battery-success.json"
    case batterySocSuccess = "battery-soc-success.json"
    case reportSuccess = "report-success.json"
    case loginSuccess = "login-success.json"

    case loginFailure = "login-failure.json"
    case tryLaterFailure = "trylater.json"
    case badTokenFailure = "badtoken.json"
}
