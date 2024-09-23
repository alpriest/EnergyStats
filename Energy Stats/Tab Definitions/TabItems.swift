//
//  TabItems.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/09/2024.
//

import Energy_Stats_Core
import SwiftUI

struct PowerFlowTabItem: View {
    var body: some View {
        TabItem(accessibilityIdentifier: "power_flow_tab") {
            Image(systemName: "arrow.up.arrow.down")
            Text("Power flow")
        }
    }
}

struct StatsTabItem: View {
    var body: some View {
        TabItem(accessibilityIdentifier: "stats_tab") {
            Image(systemName: "chart.bar.xaxis")
            Text("Stats")
        }
    }
}

struct ParametersTabItem: View {
    var body: some View {
        TabItem(accessibilityIdentifier: "parameters_tab") {
            Image(systemName: "chart.xyaxis.line")
            Text("Parameters")
        }
    }
}

struct SummaryTabItem: View {
    var body: some View {
        TabItem(accessibilityIdentifier: "summary_tab") {
            if #available(iOS 17.0, *) {
                Image(systemName: "book.pages")
            } else {
                Image(systemName: "book")
            }
            Text("Summary")
        }
    }
}

struct SettingsTabItem: View {
    let configManager: ConfigManaging

    var body: some View {
        TabItem(accessibilityIdentifier: "settings_tab") {
            Image(systemName: "gearshape")
            Text("Settings")
        }
        .if(configManager.isDemoUser) {
            $0.badge("demo")
        }
    }
}

struct TabItem<Content: View>: View {
    let accessibilityIdentifier: String
    let content: Content

    init(accessibilityIdentifier: String, @ViewBuilder content: @escaping () -> Content) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    var body: some View {
        Group {
#if targetEnvironment(macCatalyst)
            HStack {
                content
            }
#else
            VStack {
                content
            }
#endif
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
