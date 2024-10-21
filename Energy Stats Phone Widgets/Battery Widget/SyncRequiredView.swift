//
//  SyncRequiredView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct SyncRequiredView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
            default:
                defaultBody()
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    func defaultBody() -> some View {
        VStack(spacing: 24) {
            HStack {
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                Text("Sync Required")
            }
            .font(titleFont)

            if family != .accessoryRectangular {
                Text("Please open Energy Stats to synchronise data")
                    .multilineTextAlignment(.center)
                    .font(bodyFont)
            }
        }
    }

    var titleFont: Font {
        switch family {
        case .systemSmall, .accessoryRectangular:
            .body
        default:
            .title
        }
    }

    var bodyFont: Font {
        switch family {
        case .systemSmall, .accessoryRectangular:
            .caption
        default:
            .body
        }
    }
}

struct SyncRequiredView_Previews: PreviewProvider {
    static var previews: some View {
        SyncRequiredView()
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

        SyncRequiredView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
