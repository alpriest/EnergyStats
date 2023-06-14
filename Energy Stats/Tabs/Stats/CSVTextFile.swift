//
//  CSVTextFile.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVExporting: ViewModifier {
    @Binding var isShowing: Bool
    let file: CSVTextFile?
    let filename: String

    func body(content: Content) -> some View {
        content
            .fileExporter(isPresented: $isShowing, document: file, contentType: .commaSeparatedText, defaultFilename: filename) { _ in }
    }
}

extension View {
    func csvExporting(isShowing: Binding<Bool>, file: CSVTextFile?, filename: String) -> some View {
        modifier(CSVExporting(isShowing: isShowing, file: file, filename: filename))
    }
}

struct CSVTextFile: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writeableContentTypes = [UTType.commaSeparatedText]

    private let text: String

    init(initialText: String) {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        text = ""
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
