//
//  ExternalWebNavigationLink.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ExternalWebNavigationLink: View {
    let url: String
    let title: LocalizedString.Key

    var body: some View {
        Button {
            let url = URL(string: url)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } label: {
            NavigationLink {
                EmptyView()
            } label: {
                Text(String(key: title))
            }
        }
        .buttonStyle(.automatic)
        .tint(Color(uiColor: UIColor.label))
    }
}

#if DEBUG
struct ExternalWebNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        ExternalWebNavigationLink(
            url: "https://www.foxesscommunity.com",
            title: .foxessCommunity
        )
    }
}
#endif
