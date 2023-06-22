//
//  CSVTextFile.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVTextFile {
    let url: URL?

    init?(text: String, filename: String) {
        self.url = CSVTextFile.save(filename: filename, text: text)

        if self.url == nil {
            return nil
        }
    }

    static func save(filename: String, text: String) -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let tempFileURL = tempDirectoryURL.appendingPathComponent(filename)
        try? fileManager.removeItem(at: tempFileURL) 

        do {
            try text.write(to: tempFileURL, atomically: true, encoding: .utf8)
            return tempFileURL
        } catch {
            // Handle any exceptions that may occur while saving the file
            print("Error saving file: \(error)")
        }

        return nil
    }
}
