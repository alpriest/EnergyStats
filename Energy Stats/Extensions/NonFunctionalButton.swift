//
//  NonFunctionalButton.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/05/2023.
//

import SwiftUI

struct NonFunctionalButton<Content: View>: View {
    let label: Content

    init(@ViewBuilder label: () -> Content) {
        self.label = label()
    }

    var body: some View {
        Button(action: {}, label: { label })
            .buttonStyle(.bordered)
    }
}

struct NonFunctionalButton_Previews: PreviewProvider {
    static var previews: some View {
        NonFunctionalButton {
            Text(Calendar.current.shortMonthSymbols[1])
                .frame(minWidth: 35)
            Image(systemName: "chevron.up.chevron.down")
                .font(.footnote)
        }
    }
}
