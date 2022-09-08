//
//  ContentView.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct ContentView: View {
    let networking: Networking

    var body: some View {
        TabView {
            SummaryTabView(viewModel: SummaryTabViewModel(networking))
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                }

            GraphTabView(viewModel: GraphTabViewModel(networking))
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
    }
}
