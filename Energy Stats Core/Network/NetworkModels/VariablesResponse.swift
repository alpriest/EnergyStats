//
//  VariablesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/05/2023.
//

import Foundation

public struct VariablesResponse: Decodable {
    let variables: [RawVariable]
}
