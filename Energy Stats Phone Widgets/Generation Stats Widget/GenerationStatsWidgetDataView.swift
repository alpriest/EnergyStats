//
//  GenerationStatsWidgetDataView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct GenerationStatsWidgetDataView: View {
    let today: Double?
    let month: Double?
    let cumulative: Double?

    var body: some View {
        HStack {
            if let value = today {
                boxed(value, label: "today")
            }
            Spacer()
            if let value = month {
                boxed(value, label: "month")
            }
            Spacer()
            if let value = cumulative {
                boxed(value, label: "cumulative")
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }

    private func boxed(_ value: Double, label: String) -> some View {
        Color.white.overlay(
            VStack(alignment: .center, spacing: 12) {
                Text(value.roundedToString(decimalPlaces: 1))
                +
                Text("kw")
                    .font(.system(size: 8.0))

                Text(label)
                    .font(.system(size: 12.0))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .shadow(color: Color.black.opacity(0.2), radius: 15)
        .padding(.vertical)
    }
}

struct GenerationStatsWidgetDataView_Previews: PreviewProvider {
    static var previews: some View {
        GenerationStatsWidgetDataView(
            today: 2.3,
            month: 14.9,
            cumulative: 243.1
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.yellow.opacity(0.2),
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
