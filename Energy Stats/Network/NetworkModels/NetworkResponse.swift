//
//  NetworkResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 24/09/2022.
//

import Foundation

struct NetworkResponse<T: Decodable>: Decodable {
    let errno: Int
    let result: T?
}
