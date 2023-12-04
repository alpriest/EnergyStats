//
//  ScheduleTemplateListView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleTemplateListView: View {
    @StateObject var viewModel: ScheduleTemplateListViewModel
    @State private var selectedTemplateID: String?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleTemplateListViewModel(networking: networking, config: config))
    }

    var body: some View {
        Form {
            Section {
                Picker("Template", selection: $selectedTemplateID) {
                    Text("Choose").tag(nil as String?)

                    ForEach(viewModel.templates) {
                        Text($0.name)
                            .tag($0.id as String?)
                    }
                }
            } header: {
                Text("")
            }
        }
            .onAppear { Task { await viewModel.load() } }
    }
}

#Preview {
    ScheduleTemplateListView(
        networking: DemoNetworking(),
        config: PreviewConfigManager()
    )
}
