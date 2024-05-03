//
//  GridPowerView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 03/05/2024.
//

import Energy_Stats_Core
import SwiftUI

struct GridPowerView: View {
    let value: Double?

    var body: some View {
        return VStack(alignment: .center) {
            PylonView()
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(value == nil ? .iconDisabled : value.tintColor)

            HStack {
                if let value {
                    Text(abs(value).kW(2))
                } else {
                    Text("xxxxx")
                        .redacted(reason: .placeholder)
                }
            }
        }
    }
}

#Preview {
    GridPowerView(value: 2.0)
}
