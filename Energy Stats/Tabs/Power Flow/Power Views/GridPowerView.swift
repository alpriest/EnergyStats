//
//  GridPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct GridPowerView: View {
    let amount: Double
    let gridExportTotal: Double
    let gridImportTotal: Double
    let iconFooterHeight: Double
    let appTheme: AppTheme
    @AppStorage("gridPowerView_showImportTotal") private var showImport: Bool = false

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: true, type: .gridFlow)
            PylonView(lineWidth: 3)
                .frame(width: 45, height: 45)

            VStack {
                if appTheme.showGridTotalsOnPowerFlow {
                    Group {
                        if showImport {
                            EnergyText(amount: gridImportTotal, appTheme: appTheme, type: .totalImport)
                            Text("import_total")
                                .font(.caption)
                                .foregroundColor(Color("text_dimmed"))
                        } else {
                            EnergyText(amount: gridExportTotal, appTheme: appTheme, type: .totalExport)
                            Text("export_total")
                                .font(.caption)
                                .foregroundColor(Color("text_dimmed"))
                        }
                    }.onTapGesture {
                        showImport.toggle()
                    }
                }

                Spacer()
            }
            .frame(height: iconFooterHeight)
        }
    }
}

struct GridPowerView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerView(amount: 0.4,
                      gridExportTotal: 2.4,
                      gridImportTotal: 0.3,
                      iconFooterHeight: 32,
                      appTheme: AppTheme.mock())
    }
}
