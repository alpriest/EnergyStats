//
//  AddressBookResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation

struct AddressBookResponse: Decodable {
    let softVersion: SoftwareVersion

    struct SoftwareVersion: Decodable {
        let master: String
        let slave: String
        let manager: String
    }
}
