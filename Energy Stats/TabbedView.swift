//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct TabbedView: View {
    let config: Config
    let networking: Networking
    let userManager: UserManager
    @StateObject var summaryViewModel: PowerFlowTabViewModel
    @StateObject var graphViewModel: GraphTabViewModel

    init(networking: Networking, userManager: UserManager, config: Config) {
        self.networking = networking
        self.userManager = userManager
        self.config = config
        _summaryViewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, config: config))
        _graphViewModel = .init(wrappedValue: GraphTabViewModel(networking))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(viewModel: summaryViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                }

            GraphTabView(viewModel: graphViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "lines.measurement.horizontal")
                        Text("Graphs")
                    }
                }

            SettingsTabView(userManager: userManager, config: config)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView(networking: MockNetworking(), userManager: UserManager(networking: MockNetworking(), store: KeychainStore(), config: MockConfig()), config: MockConfig())
    }
}
