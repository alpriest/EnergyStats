//
//  String+URL.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2024.
//

import UIKit

public extension UIApplication {
    func open(_ url: String) {
        guard let url = URL(string: url) else { return }

        self.open(url)
    }
}
