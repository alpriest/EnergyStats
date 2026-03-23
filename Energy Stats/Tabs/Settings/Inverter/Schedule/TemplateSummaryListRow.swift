//
//  TemplateSummaryListRow.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/10/2024.
//

import Energy_Stats_Core
import SwiftUI

struct TemplateSummaryListRow: View {
    let template: ScheduleTemplate
    let networking: Networking
    let config: ConfigManaging
    let templateStore: TemplateStoring
    @ObservedObject var viewModel: ScheduleSummaryViewModel
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        List {
            NavigationLink {
                EditTemplateView(
                    networking: networking,
                    templateStore: templateStore,
                    configManager: config,
                    template: template
                )
            } label: {
                VStack(alignment: .leading) {
                    Text(template.name)

                    ScheduleView(schedule: template.asSchedule(), includePhaseDetail: false)
                        .padding(.vertical, 4)
                }
            }

            Button {
                Task {
                    await viewModel.activate(template)
                    requestReview()
                }
            } label: {
                Text("Activate")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
