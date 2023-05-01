//
//  String+MD5.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 01/05/2023.
//

import Foundation
import CryptoKit

public extension String {
    func md5() -> String? {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
