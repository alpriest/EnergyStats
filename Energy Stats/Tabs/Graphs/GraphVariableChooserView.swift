//
//  GraphVariableChooserView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct GraphVariableChooserView: View {
    @Binding var variables: [GraphVariable]

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct VariableChooser_Previews: PreviewProvider {
    static var previews: some View {
        var variables = [RawVariable(name: "PV1Volt", variable: "pv1Volt", unit: "V"),
                         RawVariable(name: "PV1Current", variable: "pv1Current", unit: "A"),
                         RawVariable(name: "PV1Power", variable: "pv1Power", unit: "kW"),
                         RawVariable(name: "PVPower", variable: "pvPower", unit: "kW"),
                         RawVariable(name: "PV2Volt", variable: "pv2Volt", unit: "V"),
                         RawVariable(name: "PV2Current", variable: "pv2Current", unit: "A"),
                         RawVariable(name: "PV2Power", variable: "pv2Power", unit: "kW")].map { GraphVariable($0) }
        let boundVariables = Binding(get: { variables }, set: { variables = $0})

        return GraphVariableChooserView(variables: boundVariables)
    }
}
