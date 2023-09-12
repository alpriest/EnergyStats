//
//  AddressBookResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation

public struct AddressBookResponse: Codable {
    let softVersion: SoftwareVersion

    public struct SoftwareVersion: Codable {
        let master: String
        let slave: String
        let manager: String
    }
}
