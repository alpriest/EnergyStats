//
//  Credentials.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

class Credentials: ObservableObject {
    @UserDefaultsStored(key: "username")
    var username: String?

    @UserDefaultsStored(key: "password")
    var password: String?

    @Published var hasCredentials = false

    init() {
        hasCredentials = username != nil && password != nil
    }
}

extension Credentials {
    var hashedPassword: String? {
        password?.md5()
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
