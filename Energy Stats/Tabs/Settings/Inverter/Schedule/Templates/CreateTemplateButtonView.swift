//
//  CreateTemplateButtonView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/07/2024.
//

import Energy_Stats_Core
import SwiftUI

struct CreateTemplateAlertViewModifier: ViewModifier {
    private var newTemplateName: Binding<String>
    private var isPresented: Binding<Bool>
    private let action: (String) async -> Void

    init(newTemplateName: Binding<String>, isPresented: Binding<Bool>, action: @escaping (String) async -> Void) {
        self.newTemplateName = newTemplateName
        self.isPresented = isPresented
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .alert("New template", isPresented: isPresented, actions: {
                TextField("Name", text: newTemplateName)

                Button("Create", action: {
                    Task {
                        await action(newTemplateName.wrappedValue)
                        newTemplateName.wrappedValue = ""
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            })
    }
}

extension View {
    func createTemplateAlert(newTemplateName: Binding<String>, isPresented: Binding<Bool>, action: @escaping (String) async -> Void) -> some View {
        modifier(CreateTemplateAlertViewModifier(newTemplateName: newTemplateName, isPresented: isPresented, action: action))
    }
}
