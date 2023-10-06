//
//  UrlOpener.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/10/2023.
//

import Foundation
#if os(iOS)
import UIKit
#endif

final class UrlOpener {
    static func open(_ url: URL) {
        #if os(iOS)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #elseif macOS
        NSWorkspace.shared.open(url)
        #endif
    }
}
