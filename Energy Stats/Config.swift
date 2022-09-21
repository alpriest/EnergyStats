//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import CryptoKit
import Foundation

class Config {
    static var shared: Config {
        Config()
    }

    @UserDefaultsStored(key: "minSOC")
    var minSOC: String?

    @UserDefaultsStored(key: "batteryCapacity")
    var batteryCapacity: String?

    @UserDefaultsStored(key: "deviceID")
    var deviceID: String?

    var hasBattery: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasBattery")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasBattery")
        }
    }

    var hasPV: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasPV")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasPV")
        }
    }
}

extension String {
    func md5() -> String? {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

@propertyWrapper
struct UserDefaultsStored {
    var key: String

    var wrappedValue: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
