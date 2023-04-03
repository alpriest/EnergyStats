//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 03/04/2023.
//

import SwiftUI
import Energy_Stats_Core

struct ContentView: View {
    let solar: Double
    let grid: Double
    let batteryAvailableCapacity: Double
    let batteryMessage: String

    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: [GridItem(.fixed(45)), GridItem(.flexible())], spacing: 10) {
                    Image(systemName: "sun.max")
                        .font(.system(size: 32))

                    HStack {
                        Text(NSNumber(value: solar), formatter: formatter) + Text(" kW")
                    }

                    PylonView()
                        .frame(width: 34, height: 30)

                    HStack {
                        if grid < 0 {
                            Image(systemName: "arrow.left")
                        }
                        Text(NSNumber(value: abs(grid)), formatter: formatter) + Text(" kW")
                        if grid > 0 {
                            Image(systemName: "arrow.right")
                        }
                    }.foregroundColor(grid > 0 ? Color.green : Color.red)

                    Image(systemName: "minus.plus.batteryblock.fill")
                        .font(.system(size: 32))

                    VStack {
                        Text("98%")
                        Text("Empty in 19 hours")
                            .font(.footnote)
                    }
                }
                .padding(.bottom, 12)

                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("3/Apr 17:21")
                        .font(.footnote)
                }
            }
        }
        .padding()
    }

    let formatter: NumberFormatter = {
        let result = NumberFormatter()
        result.maximumFractionDigits = 3
        result.minimumFractionDigits = 3
        return result
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(
                solar: 1.5,
                grid: 0.5,
                batteryAvailableCapacity: 0.97,
                batteryMessage: "Empty in 19 hours"
            )

            ContentView(
                solar: 1.5,
                grid: -0.5,
                batteryAvailableCapacity: 0.97,
                batteryMessage: "Empty in 19 hours"
            )
        }
    }
}
