//
//  ContentView.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct ContentView: View {
    let networking: Networking
    private let summaryViewModel: SummaryTabViewModel
    private let graphViewModel: GraphTabViewModel

    init(networking: Networking) {
        self.networking = networking
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networking: MockNetworking())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
