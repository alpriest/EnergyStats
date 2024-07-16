//
//  AsyncButton.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 15/07/2024.
//

import SwiftUI

public struct AsyncButton<Label: View>: View {
    public let action: () async -> Void
    public let label: () -> Label

    public init(action: @escaping () async -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: { Task { await action() } }, label: label)
    }
}

#Preview {
    AsyncButton {
        // TODO:
    } label: {
        Text("Create new template")
    }
}
