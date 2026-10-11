//
//  SlowServerBannerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/07/2024.
//

import Energy_Stats_Core
import SwiftUI

enum BannerAlertType {
    case offline
}

@Observable
class BannerAlertManager {
    var bannerAlert: BannerAlertType? = nil
    private var seenOfflineBanner = false
    
    init(bannerAlert: BannerAlertType? = nil) {
        self.bannerAlert = bannerAlert

        NotificationCenter.default.addObserver(forName: .deviceIsOffline, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }

            if !seenOfflineBanner {
                self.bannerAlert = .offline
                seenOfflineBanner = true
            }
        }
    }
}

struct BannerAlertView: View {
    @Environment(BannerAlertManager.self) private var alertManager: BannerAlertManager

    var body: some View {
        VStack {
            switch alertManager.bannerAlert {
            case .offline:
                OfflineDeviceBannerView()
            case nil:
                EmptyView()
            }

            Spacer()
        }
    }
}

#Preview {
    VStack {
        BannerAlertView()
    }
    .environment(BannerAlertManager(bannerAlert: .offline))
}
