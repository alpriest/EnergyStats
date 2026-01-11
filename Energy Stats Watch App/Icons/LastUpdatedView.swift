//
//  LastUpdatedView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 10/01/2026.
//

import SwiftUI

struct LastUpdatedView: View {
    let lastUpdated: Date?

    var body: some View {
        VStack {
            if let lastUpdated {
                Text("Last updated")
                    .padding(.bottom, 22)
                Text(lastUpdated, format: .dateTime)
            } else {
                Text("Loading...")
            }
        }
    }
}

#Preview {
    LastUpdatedView(lastUpdated: nil)
}

#Preview {
    LastUpdatedView(lastUpdated: .now)
}
