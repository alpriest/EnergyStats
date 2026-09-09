//
//  LastUpdatedView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 10/01/2026.
//

import Energy_Stats_Core
import SwiftUI

struct LastUpdatedView: View {
    @Environment(\.locale) private var locale

    let lastUpdated: Date?

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                if let lastUpdated {
                    VStack {
                        Text("Last updated")
                        Text(lastUpdated, format: .dateTime)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Red text")
                            .foregroundStyle(Color.linesNegative)
                            .font(.system(size: 16, weight: .bold)) + Text(" ") +
                        Text("shows battery discharge and grid import")

                        Text("Green text")
                            .foregroundStyle(Color.linesPositive)
                            .font(.system(size: 16, weight: .bold)) + Text(" ") +
                        Text("shows battery charge and grid export")
                    }
                } else {
                    Text("Loading...")
                }
            }
        }
    }
}

#Preview {
    LastUpdatedView(lastUpdated: .now)
        .environment(\.locale, .init(identifier: "de"))
}

#Preview {
    LastUpdatedView(lastUpdated: nil)
}
