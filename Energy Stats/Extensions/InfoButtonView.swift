//
//  InfoButtonView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct InfoButtonView: View {
    @State private var alert: AlertContent?
    let message: LocalizedStringKey

    var body: some View {
        Button {
            alert = AlertContent(title: "", message: message)
        } label: {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.blue)
        }
        .buttonStyle(PlainButtonStyle())
        .alert(alertContent: $alert)
    }
}

#Preview {
    InfoButtonView(message: "Something")
}
