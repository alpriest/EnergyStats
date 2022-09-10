//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct TabbedView: View {
    let networking: Networking
    let credentials: Credentials
    private let summaryViewModel: SummaryTabViewModel
    private let graphViewModel: GraphTabViewModel

    init(networking: Networking, credentials: Credentials) {
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

            GraphTabView(viewModel: graphViewModel, credentials: credentials)
                .tabItem {
                    VStack {
                        Image(systemName: "lines.measurement.horizontal")
                        Text("Graphs")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView(networking: MockNetworking(), credentials: Credentials())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
