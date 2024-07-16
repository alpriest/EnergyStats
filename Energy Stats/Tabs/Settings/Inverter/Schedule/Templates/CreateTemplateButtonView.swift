//
//  CreateTemplateButtonView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/07/2024.
//

import Energy_Stats_Core
import SwiftUI

struct CreateTemplateButtonView: View {
    @State private var newTemplateName: String = ""
    @State private var showing = false
    let action: (String) async -> Void
    let label: String

    init(action: @escaping (String) async -> Void, label: String = "Create new template") {
        self.action = action
        self.label = label
    }

    var body: some View {
        AsyncButton {
            showing = true
        } label: {
            Text(label)
        }
        .buttonStyle(.borderedProminent)
        .alert("New template", isPresented: $showing, actions: {
            TextField("Name", text: $newTemplateName)

            Button("Create", action: {
                Task {
                    await action(newTemplateName)
                    newTemplateName = ""
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
}

#Preview {
    CreateTemplateButtonView(action: { _ in })
}
