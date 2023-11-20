//
//  UserDefaultsPropertyWrappers.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

@propertyWrapper
public struct UserDefaultsStoredInt {
    var key: String
    var defaultValue: Int = 0

    public var wrappedValue: Int {
        get {
            (UserDefaults.shared.object(forKey: key) as? Int) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredDouble {
    var key: String
    var defaultValue: Double = 0.0

    public var wrappedValue: Double {
        get {
            (UserDefaults.shared.object(forKey: key) as? Double) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredOptionalString {
    var key: String

    public var wrappedValue: String? {
        get {
            UserDefaults.shared.string(forKey: key)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredString {
    var key: String
    var defaultValue: String

    public var wrappedValue: String {
        get {
            UserDefaults.shared.string(forKey: key) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredBool {
    var key: String
    var defaultValue: Bool = false

    public var wrappedValue: Bool {
        get {
            (UserDefaults.shared.object(forKey: key) as? Bool) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredData {
    var key: String

    public var wrappedValue: Data? {
        get {
            UserDefaults.shared.data(forKey: key)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredCodable<T: Codable> {
    var key: String
    var defaultValue: T

    public var wrappedValue: T {
        get {
            guard let data = UserDefaults.shared.data(forKey: key) else {
                return defaultValue
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.shared.set(data, forKey: key)
            } catch {
                print("AWP", "Failed to encode value for \(key) 💥")
            }
        }
    }
}
