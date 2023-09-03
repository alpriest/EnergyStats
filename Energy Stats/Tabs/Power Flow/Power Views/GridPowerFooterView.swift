//
//  GridPowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct GridPowerFooterView: View {
    @AppStorage("gridPowerView_showImportTotal") private var showImport: Bool = false
    let importTotal: Double
    let exportTotal: Double
    let appTheme: AppTheme

    var body: some View {
        VStack(alignment: .center) {
            if appTheme.showGridTotalsOnPowerFlow {
                Group {
                    if showImport {
                        EnergyText(amount: importTotal, appTheme: appTheme, type: .totalImport)
                        Text("import_total")
                            .font(.caption)
                            .foregroundColor(Color("text_dimmed"))
                    } else {
                        EnergyText(amount: exportTotal, appTheme: appTheme, type: .totalExport)
                        Text("export_total")
                            .font(.caption)
                            .foregroundColor(Color("text_dimmed"))
                    }
                }.onTapGesture {
                    showImport.toggle()
                }
            }
        }
    }
}

struct GridPowerFooterView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerFooterView(
            importTotal: 1.0, exportTotal: 2.0, appTheme: .mock()
        )
    }
}
