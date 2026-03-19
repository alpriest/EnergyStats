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
    @FocusState private var focusedField: Field?
    @State private var showingAdvanced = false
    
    private enum Field: Hashable {
        case minSoc
        case maxSoc
        case forceChargeSoc
        case forceDischargeSoc
        case forceChargePower
        case forceDischargePower
        case pvLimit
    }
    
    init(
        phase: SchedulePhase,
        configManager: ConfigManaging,
        onChange: @escaping (SchedulePhase) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.onDelete = onDelete
        self._viewModel = StateObject(
            wrappedValue: SchedulePhaseEditViewModel(
                configManager: configManager,
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
    
    private var minSocEditable: some View {
        EditableItemView(
            title: "Min SoC",
            field: Field.minSoc,
            numberTitle: "Min SoC",
            numberText: $viewModel.viewData.minSOC,
            unit: "%",
            error: viewModel.minSOCError,
            description: minSoCDescription(),
            focusedField: $focusedField
        )
    }
    
    private var maxSocEditable: some View {
        EditableItemView(
            title: "Max SoC",
            field: Field.maxSoc,
            numberTitle: "Max SoC",
            numberText: $viewModel.viewData.maxSOC,
            unit: "%",
            error: viewModel.maxSOCError,
            description: nil,
            focusedField: $focusedField
        )
    }
    
    private var forceChargeSocEditable: some View {
        EditableItemView(
            title: "Force Charge SoC",
            field: Field.forceChargeSoc,
            numberTitle: "SoC",
            numberText: $viewModel.viewData.fdSOC,
            unit: "%",
            error: nil,
            description: nil,
            focusedField: $focusedField
        )
    }

    private var forceDischargeSocEditable: some View {
        EditableItemView(
            title: "Force Discharge SoC",
            field: Field.forceDischargeSoc,
            numberTitle: "SoC",
            numberText: $viewModel.viewData.fdSOC,
            unit: "%",
            error: viewModel.fdSOCError,
            description: forceDischargeSoCDescription(),
            focusedField: $focusedField
        )
    }
    
    private var forceChargePowerEditable: some View {
        EditableItemView(
            title: "Force Charge Power",
            field: Field.forceChargePower,
            numberTitle: "Power",
            numberText: $viewModel.viewData.fdPower,
            unit: "W",
            error: nil,
            description: nil,
            focusedField: $focusedField
        )
    }

    private var forceDischargePowerEditable: some View {
        EditableItemView(
            title: "Force Discharge Power",
            field: Field.forceDischargePower,
            numberTitle: "Power",
            numberText: $viewModel.viewData.fdPower,
            unit: "W",
            error: viewModel.forceDischargePowerError,
            description: forceDischargePowerDescription(),
            focusedField: $focusedField
        )
    }
    
    private var pvLimitEditable: some View {
        EditableItemView(
            title: "PV Limit",
            field: Field.pvLimit,
            numberTitle: "Power",
            numberText: $viewModel.viewData.pvLimit,
            unit: "W",
            error: nil,
            description: nil,
            focusedField: $focusedField
        )
    }
    
    private func minSoCDescription() -> LocalizedStringKey? {
        return "The minimum battery state of charge."
    }
    
    private func forceDischargeSoCDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = viewModel.viewData.workMode {
            return "When the battery reaches this level, discharging will stop. If you wanted to save some battery power for later, perhaps set it to 50%."
        }
        
        return nil
    }
    
    private func forceDischargePowerDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = viewModel.viewData.workMode {
            return "The output power level to be delivered, including your house load and grid export. E.g. If you have 5kW inverter then set this to 5000, then if the house load is 750W the other 4.25kW will be exported."
        }
        
        return nil
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
        Section {
            switch workMode {
            case .SelfUse:
                minSocEditable
            case .Feedin:
                minSocEditable
            case .Backup:
                minSocEditable
            case .ForceCharge:
                forceChargeSocEditable
            case .ForceDischarge:
                forceDischargeSocEditable
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    func advancedViews(for workMode: WorkMode) -> some View {
        Section {
            if showingAdvanced {
                switch workMode {
                case .ForceCharge:
                    forceChargePowerEditable
                    pvLimitEditable
                case .ForceDischarge:
                    forceDischargePowerEditable
                    minSocEditable
                default:
                    EmptyView()
                }
            }
        } footer: {
            if !showingAdvanced && hasAdvancedViews(for: workMode) {
                Button(action: { showingAdvanced = true }) {
                    Text("More...")
                }
            }
        }
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
        phase: SchedulePhase(
            enabled: true,
            start: Time(
                hour: 19,
                minute: 30
            ),
            end: Time(
                hour: 23,
                minute: 30
            ),
            mode: "ForceDischarge",
            minSocOnGrid: 10,
            forceDischargePower: 3500,
            forceDischargeSOC: 20,
            maxSOC: 100,
            color: Color.scheduleColor(named: "ForceDischarge"),
            pvLimit: nil
        )!,
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
