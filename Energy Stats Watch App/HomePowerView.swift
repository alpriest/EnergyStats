//
//  HomePowerView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 03/05/2024.
//

import SwiftUI

struct HomePowerView: View {
    let value: Double?

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "house.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(Color.iconDisabled)

            if let value {
                Text(value.kW(2))
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }
}

#Preview {
    HomePowerView(value: 0.0)
}
