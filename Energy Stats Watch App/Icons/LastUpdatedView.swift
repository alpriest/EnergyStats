//
//  LastUpdatedView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 10/01/2026.
//

import Energy_Stats_Core
import SwiftUI

struct LastUpdatedView: View {
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
                        Text(greenTextDescription)
                        Text(redTextDescription)
                    }
                } else {
                    Text("Loading...")
                }
            }
        }
    }

    private var greenTextDescription: AttributedString {
        var text = AttributedString("Green text shows battery charge and grid export")
        if let range = text.range(of: "Green text") {
            text[range].foregroundColor = Color.linesPositive
            text[range].font = UIFont.boldSystemFont(ofSize: 16)
        }
        return text
    }

    private var redTextDescription: AttributedString {
        var text = AttributedString("Red text shows battery charge and grid import")
        if let range = text.range(of: "Red text") {
            text[range].foregroundColor = Color.linesNegative
            text[range].font = UIFont.boldSystemFont(ofSize: 16)
        }
        return text
    }
}

#Preview {
    LastUpdatedView(lastUpdated: .now)
}

#Preview {
    LastUpdatedView(lastUpdated: nil)
}
