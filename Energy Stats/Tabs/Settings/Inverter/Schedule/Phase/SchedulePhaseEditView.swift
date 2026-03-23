//
//  SchedulePhaseEditView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    private let onDelete: (String) -> Void
    @StateObject private var viewModel: SchedulePhaseEditViewModel
    @FocusState private var focusedField: String?
    @State private var showingAdvanced = false
        
    init(
        schedule: Schedule,
        phase: SchedulePhaseV3,
        configManager: ConfigManaging,
        onChange: @escaping (SchedulePhaseV3) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.onDelete = onDelete
        self._viewModel = StateObject(
            wrappedValue: SchedulePhaseEditViewModel(
                configManager: configManager,
                schedule: schedule,
                phase: phase,
                onChange: onChange,
                onDelete: onDelete
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                FooterSection {
                    Text("Define your phase here. Press back to view your entire schedule.")
                }
                
                Section {
                    CustomTimePicker(start: $viewModel.viewData.startTime, end: $viewModel.viewData.endTime, includeSeconds: true)
                    
                    Picker(selection: $viewModel.viewData.workMode) {
                        ForEach(viewModel.viewData.modes, id: \.self) { mode in
                            Text(WorkMode.title(for: mode))
                        }
                    } label: {
                        HStack {
                            Text("Work Mode")
                            OptionalView(workModeDescription()) {
                                InfoButtonView(message: $0)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                } footer: {
                    VStack {
                        OptionalView(viewModel.timeError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                
                standardViews(for: viewModel.viewData.workMode)
                advancedViews(for: viewModel.viewData.workMode)
                
                Section {}
                footer: {
                        Button(role: .destructive) {
                            onDelete(viewModel.viewData.id)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Delete time period")
                        }.buttonStyle(.bordered)
                    }
            }
            
            BottomButtonsView(dirty: viewModel.isDirty) { viewModel.save {
                presentationMode.wrappedValue.dismiss()
            } }
        }
        .navigationTitle(.editPhase)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.viewData.workMode) { _ in
            showingAdvanced = false
        }
    }

    private func workModeDescription() -> LocalizedStringKey? {
        switch viewModel.viewData.workMode {
        case WorkMode.SelfUse:
            "workmode.self_use_mode.description"
        case WorkMode.Feedin:
            "workmode.feed_in_first_mode.description"
        case WorkMode.Backup:
            "workmode.backup_mode.description"
        case WorkMode.PeakShaving:
            "workmode.peak_shaving.description"
        case WorkMode.ForceCharge:
            "workmode.force_charge_mode.description"
        case WorkMode.ForceDischarge:
            "workmode.force_discharge_mode.description"
        case "ForceCharge(AC)":
            "workmode.force_charge_mode_ac.description"
        case "ForceDischarge(AC)":
            "workmode.force_discharge_mode_ac.description"
        case "ForceCharge(BAT)":
            "workmode.force_charge_mode_bat.description"
        case "ForceDischarge(BAT)":
            "workmode.force_discharge_mode_bat.description"
        default:
            nil
        }
    }
    
    @ViewBuilder
    func standardViews(for workMode: WorkMode) -> some View {
        ForEach(viewModel.viewData.fields.filter(\.isStandard), id: \.key) {
            editableItemView(for: $0)
        }
    }
    
    @ViewBuilder
    func advancedViews(for workMode: WorkMode) -> some View {
        Section {
            if showingAdvanced {
                ForEach(viewModel.viewData.fields.filter { $0.isStandard == false }, id: \.key) {
                    editableItemView(for: $0)
                }
            }
        } header: {
            if showingAdvanced {
                Text("Advanced")
            }
        } footer: {
            if !showingAdvanced, hasAdvancedViews(for: workMode) {
                Button(action: { showingAdvanced = true }) {
                    Text("Advanced...")
                }
            }
        }
    }
    
    private func editableItemView(for field: SchedulePhaseFieldDefinition) -> some View {
        EditableItemView(
            title: field.title,
            field: field.title,
            numberTitle: "",
            numberText: viewModel.binding(for: field),
            unit: field.unit ?? "",
            error: viewModel.fieldErrors[field.key],
            description: field.description,
            focusedField: $focusedField
        )
    }

    private func hasAdvancedViews(for workMode: WorkMode) -> Bool {
        switch workMode {
        case .ForceCharge:
            true
        case .ForceDischarge:
            true
        default:
            false
        }
    }
}

#Preview {
    SchedulePhaseEditView(
        schedule: .preview(),
        phase: .preview,
        configManager: ConfigManager.preview(),
        onChange: { print($0.id, " changed") },
        onDelete: { print($0, " deleted") }
    )
}

struct FooterSection<V: View>: View {
    var content: () -> V

    var body: some View {
        Section {}
            footer: { content() }
    }
}

extension SchedulePhaseV3 {
    static var preview: SchedulePhaseV3 {
        SchedulePhaseV3(
            enabled: true,
            start: Time(
                hour: 19,
                minute: 30
            ),
            end: Time(
                hour: 23,
                minute: 30
            ),
            mode: WorkMode.ForceDischarge,
            extraParam: [
                "minSocOnGrid": 10,
                "forceDischargePower": 3500,
                "forceDischargeSOC": 20,
                "maxSOC": 100,
            ]
        )
    }
}


//    private var minSocEditable: some View {
//        EditableItemView(
//            title: "Minimum battery level",
//            field: Field.minSoc,
//            numberTitle: "SoC",
//            numberText: viewModel.viewData.binding(for: "minSoc"),
//            unit: "%",
//            error: viewModel.minSOCError,
//            description: minSoCDescription(),
//            focusedField: $focusedField
//        )
//    }
//
//    private var maxSocEditable: some View {
//        EditableItemView(
//            title: "Maximum battery level",
//            field: Field.maxSoc,
//            numberTitle: "SoC",
//            numberText: $viewModel.viewData.maxSOC,
//            unit: "%",
//            error: viewModel.maxSOCError,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
//
//    private var forceChargeSocEditable: some View {
//        EditableItemView(
//            title: "Target battery SoC",
//            field: Field.forceChargeSoc,
//            numberTitle: "SoC",
//            numberText: $viewModel.viewData.fdSOC,
//            unit: "%",
//            error: nil,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
//
//    private var forceDischargeSocEditable: some View {
//        EditableItemView(
//            title: "Discharge battery level",
//            field: Field.forceDischargeSoc,
//            numberTitle: "SoC",
//            numberText: $viewModel.viewData.fdSOC,
//            unit: "%",
//            error: viewModel.fdSOCError,
//            description: forceDischargeSoCDescription(),
//            focusedField: $focusedField
//        )
//    }
//
//    private var forceChargePowerEditable: some View {
//        EditableItemView(
//            title: "Force Charge Power",
//            field: Field.forceChargePower,
//            numberTitle: "Power",
//            numberText: $viewModel.viewData.fdPower,
//            unit: "W",
//            error: nil,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
//
//    private var forceDischargePowerEditable: some View {
//        EditableItemView(
//            title: "Force Discharge Power",
//            field: Field.forceDischargePower,
//            numberTitle: "Power",
//            numberText: $viewModel.viewData.fdPower,
//            unit: "W",
//            error: viewModel.forceDischargePowerError,
//            description: forceDischargePowerDescription(),
//            focusedField: $focusedField
//        )
//    }
//
//    private var pvLimitEditable: some View {
//        EditableItemView(
//            title: "PV Limit",
//            field: Field.pvLimit,
//            numberTitle: "Power",
//            numberText: $viewModel.viewData.pvLimit,
//            unit: "W",
//            error: nil,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
//
//    private var exportLimitEditable: some View {
//        EditableItemView(
//            title: "Export Limit",
//            field: Field.exportLimit,
//            numberTitle: "Power",
//            numberText: $viewModel.viewData.exportLimit,
//            unit: "W",
//            error: nil,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
//
//    private var importLimitEditable: some View {
//        EditableItemView(
//            title: "Import Limit",
//            field: Field.importLimit,
//            numberTitle: "Power",
//            numberText: $viewModel.viewData.importLimit,
//            unit: "W",
//            error: nil,
//            description: nil,
//            focusedField: $focusedField
//        )
//    }
    
