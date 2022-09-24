//
//  HomePowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import SwiftUI

struct HomePowerView: View {
    let amount: Double
    let iconFooterSize: CGSize

    var body: some View {
        VStack {
            PowerFlowView(amount: amount)
            Image(systemName: "house.fill")
                .font(.system(size: 48))
                .frame(width: 45, height: 45)
            Color.clear.frame(width: iconFooterSize.width, height: iconFooterSize.height)
        }
    }
}

struct HomePowerView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerView(amount: 1.05, iconFooterSize: CGSize(width: 32, height: 32))
    }
}
