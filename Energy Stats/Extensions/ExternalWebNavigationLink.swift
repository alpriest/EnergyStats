//
//  ExternalWebNavigationLink.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/08/2023.
//

import SwiftUI

struct ExternalWebNavigationLink: View {
    let url: String
    let title: String

    var body: some View {
        Button {
            let url = URL(string: url)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } label: {
            NavigationLink(title, destination: EmptyView())
        }
        .buttonStyle(.automatic)
        .tint(Color(uiColor: UIColor.label))
    }
}

#if DEBUG
struct FakeNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        ExternalWebNavigationLink(
            url: "https://www.foxesscommunity.com",
            title: "FoxESS Community"
        )
    }
}
#endif
