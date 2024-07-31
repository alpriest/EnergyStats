//
//  SlowServerBannerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/07/2024.
//

import Energy_Stats_Core
import SwiftUI

class SlowServerBannerAlertManager: ObservableObject {
    @Published var isShowingAlert = false
}

struct SlowServerBannerView: View {
    @EnvironmentObject var alertManager: SlowServerBannerAlertManager

    var body: some View {
        Button {
            alertManager.isShowingAlert = true
        } label: {
            Text("Always loading? Tap for details")
                .font(.footnote)
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundStyle(Color.white)
                .background(Color.red)
        }
    }
}

struct SlowServerMessageView: View {
    @EnvironmentObject var alertManager: SlowServerBannerAlertManager

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Slow performance")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                Text("slow-performance-message")
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)

                Image("server-performance")
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Button(action: {
                    alertManager.isShowingAlert = false
                }, label: {
                    Text("OK")
                        .frame(minWidth: 100)
                })
                .buttonStyle(.bordered)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .padding()
        .background(
            Color.white.shadow(radius: 3)
                .padding()
        )
    }
}

#Preview {
//    SlowServerBannerView()
//        .environmentObject(SlowServerBannerAlertManager())

    SlowServerMessageView()
}
