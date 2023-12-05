//
//  EditTemplateView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct EditTemplateView: View {
    @StateObject private var viewModel: EditTemplateViewModel

    init(networking: FoxESSNetworking, config: ConfigManaging, templateID: String, modes: [SchedulerModeResponse]) {
        _viewModel = StateObject(
            wrappedValue: EditTemplateViewModel(
                networking: networking,
                config: config,
                templateID: templateID,
                modes: modes
            )
        )
    }

    var body: some View {
        Group {
            OptionalView(viewModel.schedule) {
                EditScheduleView(
                    networking: viewModel.networking,
                    config: viewModel.config,
                    schedule: $0,
                    modes: viewModel.modes,
                    allowDeletion: false,
                    allowSaveAsActiveSchedule: false,
                    allowSavingTemplate: true
                )
            }
        }
    }
}

#Preview {
    EditTemplateView(
        networking: DemoNetworking(),
        config: PreviewConfigManager(),
        templateID: "abc",
        modes: SchedulerModeResponse.preview()
    )
}
