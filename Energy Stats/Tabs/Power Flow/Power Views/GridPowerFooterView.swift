//
//  GridPowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct GridPowerFooterView: View {
    let importTotal: Double?
    let exportTotal: Double?
    let appSettings: AppSettings

    var body: some View {
        VStack(alignment: .center) {
            if appSettings.showGridTotalsOnPowerFlow {
                EnergyText(amount: importTotal, appSettings: appSettings, type: .totalImport)
                Text("import_total")
                    .font(.caption)
                    .foregroundColor(Color("text_dimmed"))
                    .accessibilityHidden(true)

                EnergyText(amount: exportTotal, appSettings: appSettings, type: .totalExport)
                Text("export_total")
                    .font(.caption)
                    .foregroundColor(Color("text_dimmed"))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct GridPowerFooterView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerFooterView(
            importTotal: 1.0, exportTotal: 2.0, appSettings: .mock()
        )
    }
}
