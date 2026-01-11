//
//  ExternalWebNavigationLink.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ExternalWebNavigationLink<Content: View>: View {
    let url: String
    let title: () -> Content
    
    init(url: String, @ViewBuilder title: @escaping () -> Content) {
        self.url = url
        self.title = title
    }

    var body: some View {
        Button {
            let url = URL(string: url)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } label: {
            NavigationLink {
                EmptyView()
            } label: {
                title()
            }
        }
        .buttonStyle(.automatic)
        .tint(Color(uiColor: UIColor.label))
    }
}

#if DEBUG
struct ExternalWebNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        ExternalWebNavigationLink(url: "https://www.foxesscommunity.com") {
            Text(String(key: .foxessCommunity))
        }
    }
}
#endif
