//
//  OfflineDeviceBannerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2024.
//

import Energy_Stats_Core
import SwiftUI

struct OfflineDeviceBannerView: View {
    @EnvironmentObject var alertManager: BannerAlertManager

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Offline Device")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                Text("If you’ve recently updated your WiFi settings and need help reconnecting your inverter, click below to watch a step-by-step video tutorial.")
                    .font(.body)
                    .fontWeight(.regular)

                HStack {
                    Button(action: {
                        withAnimation {
                            alertManager.bannerAlert = nil
                            UIApplication.shared.open("https://youtu.be/Gy8ASwQ984A")
                        }
                    }, label: {
                        Text("Watch")
                            .frame(minWidth: 100)
                    })
                    .buttonStyle(.bordered)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

                    Button(action: {
                        withAnimation {
                            alertManager.bannerAlert = nil
                        }
                    }, label: {
                        Text("Dismiss")
                            .frame(minWidth: 100)
                    })
                    .buttonStyle(.bordered)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }

                Text("You can also find this video link in the Settings FAQ section")
                    .font(.caption2)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(Color.background)
        .border(Color.backgroundInverted, width: 2.0)
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(Animation.easeOut, value: alertManager.bannerAlert == .offline)
    }
}

#Preview {
    OfflineDeviceBannerView()
        .environmentObject(BannerAlertManager())
}
