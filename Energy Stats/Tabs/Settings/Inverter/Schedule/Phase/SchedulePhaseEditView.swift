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

                standardViews()
                advancedViews()

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
    func standardViews() -> some View {
        ForEach(viewModel.viewData.fields.filter(\.isStandard), id: \.key) {
            editableItemView(for: $0)
        }
    }

    @ViewBuilder
    func advancedViews() -> some View {
        Section {
            if showingAdvanced {
                ForEach(viewModel.viewData.fields.filter { $0.isStandard == false }, id: \.key) {
                    editableItemView(for: $0)
                }
            }
        } header: {
            if viewModel.viewData.showAdvancedFields {
                Button(action: { withAnimation { showingAdvanced.toggle() } }) {
                    HStack {
                        Text("Advanced")
                        Image(systemName: showingAdvanced ? "chevron.up" : "chevron.down")
                    }
                }
            }
        } footer: {
            if showingAdvanced {
                Text("These settings are optional and can usually be left as default.")
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
