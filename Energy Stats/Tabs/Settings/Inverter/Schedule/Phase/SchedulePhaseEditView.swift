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
                    CustomDatePicker(start: $viewModel.viewData.startTime, end: $viewModel.viewData.endTime, includeSeconds: true)

                    Picker("Work Mode", selection: $viewModel.viewData.workMode) {
                        ForEach(viewModel.viewData.modes, id: \.self) { mode in
                            Text(WorkMode.title(for: mode))
                        }
                    }
                    .pickerStyle(.menu)
                } footer: {
                    VStack {
                        OptionalView(workModeDescription()) {
                            Text($0)
                                .monospacedDigit()
                        }

                        OptionalView(viewModel.timeError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Min SoC")
                        NumberTextField("SoC", text: $viewModel.viewData.minSOC)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(viewModel.minSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(minSoCDescription()) {
                            Text($0)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Max SoC")
                        Spacer()
                        NumberTextField("Max SoC", text: $viewModel.viewData.maxSOC)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(viewModel.maxSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge SoC")
                        Spacer()
                        NumberTextField("SoC", text: $viewModel.viewData.fdSOC)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(viewModel.fdSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(forceDischargeSoCDescription()) {
                            Text($0)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge Power")
                        Spacer()
                        NumberTextField("Power", text: $viewModel.viewData.fdPower)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("W")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(viewModel.forceDischargePowerError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(forceDischargePowerDescription()) {
                            Text($0)
                        }
                    }
                }

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
    }

    private func minSoCDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = viewModel.viewData.workMode {
            return "The minimum battery state of charge. This must be at most the Force Discharge SOC value."
        }

        return nil
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
        case WorkMode.ForceCharge:
            "workmode.force_charge_mode.description"
        case WorkMode.ForceDischarge:
            "workmode.forceDischarge.description"
        case WorkMode.PeakShaving:
            "workmode.peak_shaving.description"
        default:
            nil
        }
    }
}

#Preview {
    SchedulePhaseEditView(
        phase: SchedulePhase(
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
            color: Color.scheduleColor(named: "ForceDischarge")
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
