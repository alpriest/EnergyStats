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

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleTemplateListViewModel(networking: networking, config: config))
    }

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ScheduleTemplateListView(
        networking: DemoNetworking(),
        config: PreviewConfigManager()
    )
}
