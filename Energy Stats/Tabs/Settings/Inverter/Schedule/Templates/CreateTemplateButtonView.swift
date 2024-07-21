//
//  CreateTemplateButtonView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/07/2024.
//

import Energy_Stats_Core
import SwiftUI

enum AlertConfiguration {
    case duplicateTemplate
    case createTemplate
    case renameTemplate

    var title: LocalizedStringKey {
        switch self {
        case .createTemplate:
            return "Create template"
        case .duplicateTemplate:
            return "Duplicate template"
        case .renameTemplate:
            return "Rename template"
        }
    }

    var actionButton: LocalizedStringKey {
        switch self {
        case .createTemplate:
            return "Create"
        case .duplicateTemplate:
            return "Duplicate"
        case .renameTemplate:
            return "Rename"
        }
    }
}

struct TemplateAlertViewModifier: ViewModifier {
    private var newTemplateName: Binding<String>
    private var isPresented: Binding<Bool>
    private let action: (String) async -> Void
    private let configuration: AlertConfiguration

    init(configuration: AlertConfiguration, newTemplateName: Binding<String>, isPresented: Binding<Bool>, action: @escaping (String) async -> Void) {
        self.configuration = configuration
        self.newTemplateName = newTemplateName
        self.isPresented = isPresented
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .alert(configuration.title, isPresented: isPresented, actions: {
                TextField("Name", text: newTemplateName)

                Button(configuration.actionButton, action: {
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
    func templateAlert(configuration: AlertConfiguration, newTemplateName: Binding<String>, isPresented: Binding<Bool>, action: @escaping (String) async -> Void) -> some View {
        modifier(
            TemplateAlertViewModifier(
                configuration: configuration,
                newTemplateName: newTemplateName,
                isPresented: isPresented,
                action: action
            )
        )
    }
}
