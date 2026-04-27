//
//  WatchDebugDataView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 27/04/2026.
//

import SwiftUI

struct WatchDebugDataView: View {
    let configManager: WatchConfigManaging
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Debug Data")
                    .font(.headline)
                
                VStack {
                    Text("API Key")
                    Text(configManager.apiKey ?? "none found")
                }
                
                VStack {
                    Text("Device SN")
                    Text(configManager.deviceSN ?? "none found")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.red)
    }
}

#Preview {
    WatchDebugDataView(
        configManager: WatchConfigManager()
    )
}
