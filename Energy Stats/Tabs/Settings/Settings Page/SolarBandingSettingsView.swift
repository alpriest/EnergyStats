//
//  SolarBandingSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SolarRangeView: View {
    let title: String
    @State private var lower: String
    @State private var higher: String

    init(title: String, range: ClosedRange<Int>) {
        self.title = title
        self.lower = String(describing: range.lowerBound)
        self.higher = String(describing: range.upperBound)
    }

    var body: some View {
        Section {
            HStack {
                Text("Min W")
                NumberTextField("Min W", text: $lower)
                    .multilineTextAlignment(.trailing)
            }

            HStack {
                Text("Max W")
                NumberTextField("Max W", text: $higher)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            Text(title)
        }
    }
}

struct SolarBandingSettingsView: View {
    let definitions: SolarRangeDefinitions

    var body: some View {
        VStack {
            Form {
                Section {
                    AdjustableView(config: MockConfig(), maximum: Double(definitions.range4.lowerBound + 500) / 1000.0)
                } header: {
                    Text("Try it")
                }

                SolarRangeView(title: "Range 1", range: definitions.range1)
                SolarRangeView(title: "Range 2", range: definitions.range2)
                SolarRangeView(title: "Range 3", range: definitions.range3)
                SolarRangeView(title: "Range 4", range: definitions.range4)
            }

            BottomButtonsView {
                // TODO
            }
        }
    }
}

struct SolarBandingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SolarBandingSettingsView(definitions: SolarRangeDefinitions(
            range1: 1...999,
            range2: 1000...1999,
            range3: 2000...2999,
            range4: 3000...500000
        ))
    }
}

struct SolarRangeDefinitions {
    let range1: ClosedRange<Int>
    let range2: ClosedRange<Int>
    let range3: ClosedRange<Int>
    let range4: ClosedRange<Int>
}
