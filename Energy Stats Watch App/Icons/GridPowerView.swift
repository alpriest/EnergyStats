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
    let totalExport: Double?
    let totalImport: Double?
    let iconScale: IconScale

    var body: some View {
        FullPageStatusView(
            iconScale: iconScale,
            icon: {
                ZStack {
                    PylonView(lineWidth: lineWidth)
                }
                .frame(width: iconScale.size.width * iconScaleFactor, height: iconScale.size.height * iconScaleFactor)
                .foregroundStyle(value == nil ? .iconDisabled : value.tintColor)
                .padding(.bottom, iconScale == .large ? 12 : 0)
            },
            line1: {
                Group {
                    if let value {
                        Text(value.kW(2))
                    } else {
                        Text("xxxxx")
                            .redacted(reason: .placeholder)
                    }
                }
            },
            line2: {
                Group {
                    if let totalExport, let totalImport {
                        HStack(spacing: 2) {
                            Text(totalImport.roundedToString(decimalPlaces: 1))
                                .foregroundStyle(Color.linesNegative)
                            Text("/")
                                .foregroundStyle(Color.linesNotFlowing)
                            Text(totalExport.kWh(1))
                                .foregroundStyle(Color.linesPositive)
                        }
                    } else {
                        Text(" ")
                    }
                }
            }
        )

//        VStack(alignment: .center, spacing: 0) {
//            ZStack(alignment: .bottom) {
//                Color.clear
//
//                PylonView(lineWidth: lineWidth)
//                    .frame(width: iconScale.size.width * iconScaleFactor, height: iconScale.size.height * iconScaleFactor)
//                    .foregroundStyle(value == nil ? .iconDisabled : value.tintColor)
//                    .padding(.bottom, 12)
//            }
//            .background(Color.yellow)
//            .frame(height: iconScale.size.height)
//
//            HStack {
//                if let value {
//                    Text(abs(value).kW(2))
//                } else {
//                    Text("xxxxx")
//                        .redacted(reason: .placeholder)
//                }
//            }.font(iconScale.line1Font)
//
//            if let totalExport, let totalImport {
//                HStack(spacing: 2) {
//                    Text(totalImport.roundedToString(decimalPlaces: 1))
//                        .foregroundStyle(Color.linesNegative)
//                    Text("/")
//                        .foregroundStyle(Color.linesNotFlowing)
//                    Text(totalExport.kWh(1))
//                        .foregroundStyle(Color.linesPositive)
//                }
//                .font(iconScale.line2Font)
//            }
//        }
    }

    private var iconSize: CGFloat {
        switch iconScale {
        case .small:
            36
        case .large:
            108
        }
    }

    private var lineWidth: CGFloat {
        switch iconScale {
        case .small:
            2
        case .large:
            8
        }
    }

    var iconScaleFactor: CGFloat {
        switch iconScale {
        case .small:
            1.0
        case .large:
            0.8
        }
    }
}

#Preview {
    GridPowerView(value: 2.0, totalExport: 3.4, totalImport: 2.2, iconScale: .large)
}
