//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct TabbedView: View {
    let networking: Networking
    let credentials: KeychainStore
    private let summaryViewModel: SummaryTabViewModel
    private let graphViewModel: GraphTabViewModel

    init(networking: Networking, credentials: KeychainStore) {
        self.networking = networking
        self.credentials = credentials
        summaryViewModel = SummaryTabViewModel(networking)
        graphViewModel = GraphTabViewModel(networking)
    }

    var body: some View {
        TabView {
            SummaryTabView(viewModel: summaryViewModel)
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

            SettingsTabView(credentials: credentials)
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
        TabbedView(networking: MockNetworking(), credentials: KeychainStore())
    }
}
