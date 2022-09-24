//
//  GridPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import SwiftUI

struct GridPowerView: View {
    let amount: Double
    let iconFooterSize: CGSize

    var body: some View {
        VStack {
            PowerFlowView(amount: amount)
            PylonView()
                .frame(width: 45, height: 45)
            Color.clear.frame(width: iconFooterSize.width, height: iconFooterSize.height)
        }
    }
}

struct GridPowerView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerView(amount: 0.4, iconFooterSize: CGSize(width: 32, height: 32))
    }
}
