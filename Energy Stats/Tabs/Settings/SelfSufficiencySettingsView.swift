//
//  SelfSufficiencySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/06/2023.
//

import SwiftUI
import Energy_Stats_Core

struct SelfSufficiencySettingsView: View {
    @Binding var mode: SelfSufficiencyEstimateMode
    @State private var internalMode: Int

    init(mode: Binding<SelfSufficiencyEstimateMode>) {
        self._mode = mode
        self.internalMode = mode.wrappedValue.rawValue
    }

    var body: some View {
        Section {
            Picker("Self sufficiency estimates", selection: $internalMode) {
                Text("Off").tag(0)
                Text("Net").tag(1)
                Text("Absolute").tag(2)
            }.pickerStyle(.segmented)
        } header: {
            Text("Self sufficiency estimates")
        } footer: {
            switch internalMode {
            case SelfSufficiencyEstimateMode.absolute.rawValue:
                Text("absolute_self_sufficiency")
            case SelfSufficiencyEstimateMode.net.rawValue:
                Text("net_self_sufficiency")
            default:
                Text("no_self_sufficiency")
            }
        }.onChange(of: internalMode) { newValue in
            mode = SelfSufficiencyEstimateMode(rawValue: newValue) ?? .off
        }
    }
}

struct SelfSufficiencySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SelfSufficiencySettingsView(mode: .constant(.net))
        }
    }
}
