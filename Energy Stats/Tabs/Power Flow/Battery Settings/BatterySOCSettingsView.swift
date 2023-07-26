//
//  BatterySOCSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct BatterySOCSettingsView: View {
    @Binding var soc: String
    @Binding var socOnGrid: String
    @State private var errorMessage: String?

    var body: some View {
        Section(
            content: {
                HStack {
                    Text("Min SoC")
                    TextField("Min SoC", text: $soc)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    Text("%")
                }
            },
            footer: {
                Text("The minimum charge the battery should maintain.")
            }
        )

        Section(
            content: {
                HStack {
                    Text("Min SoC on Grid")
                    TextField("Min SoC on Grid", text: $socOnGrid)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    Text("%")
                }
            },
            footer: {
                VStack(alignment: .leading) {
                    Text("The minimum charge the battery should maintain when grid power is present.")
                        .padding(.bottom)
                    Text("For the most part this is the setting that determines when the batteries will stop being used. Setting this higher than Min SoC will reserve battery power for a grid outage. For example, if you set Min SoC to 10% and Min SoC on Grid to 20%, the inverter will stop supplying power from the batteries at 20% and the house load will be supplied from the grid. If there is a grid outage, the batteries could be used (via an EPS switch) to supply emergency power until the battery charge drops to 10%.")
                        .padding(.bottom)
                    Text("If you're not sure then set both values the same.")
                }
            }
        )

        Section(content: {}, footer: {
            VStack {
                OptionalView(errorMessage) {
                    Text($0)
                        .foregroundColor(Color.red)
                }

                Button(action: {}, label: {
                    Text("Save")
                        .frame(minWidth: 0, maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
            }
        })
    }
}

struct BatterySOCSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            BatterySOCSettingsView(soc: .constant(""), socOnGrid: .constant(""))
        }
    }
}
