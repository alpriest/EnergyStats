//
//  FactoryResetAppSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/06/2025.
//

import Energy_Stats_Core
import SwiftUI

struct FactoryResetAppSettingsView: View {
    let configManager: ConfigManaging
    @State private var confirmationShowing = false
    private let checkmark = StepViewStyle.custom("checkmark.circle.fill", Color.linesPositive)
    private let xmark = StepViewStyle.custom("xmark.circle.fill", Color.linesNegative)

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Will be reset:") {
                    FullWidthVStack {
                        StepView(text: "Display settings", style: checkmark)
                        StepView(text: "Data settings", style: checkmark)
                        StepView(text: "Earnings settings", style: checkmark)
                        StepView(text: "Self sufficiency settings", style: checkmark)
                        StepView(text: "Inverter display settings, CT2 settings", style: checkmark)
                        StepView(text: "Battery display settings", style: checkmark)
                        StepView(text: "Custom parameter groups", style: checkmark)
                    }
                }

                Section("Will not be reset:") {
                    FullWidthVStack {
                        StepView(text: "Inverter schedules", style: xmark)
                        StepView(text: "Battery schedule", style: xmark)
                        StepView(text: "Battery charge levels", style: xmark)
                        StepView(text: "FoxESS API key", style: xmark)
                        StepView(text: "Solcast API key", style: xmark)
                    }
                }
            }

            BottomButtonsView(labels: BottomButtonLabels(
                left: "Cancel",
                right: "Reset..."
            )) {
                confirmationShowing.toggle()
            }
        }
        .confirmationDialog(
            "You cannot undo this action",
            isPresented: $confirmationShowing,
            titleVisibility: .visible,
            actions: {
                Button("Reset app settings", role: .destructive) {
                    configManager.resetDisplaySettings()
                }
                Button("Cancel", role: .cancel) {
                    confirmationShowing = false
                }
            }
        )
        .navigationTitle("Reset app settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        FactoryResetAppSettingsView(configManager: ConfigManager.preview())
    }
    .environment(\.locale, .init(identifier: "de"))
}
