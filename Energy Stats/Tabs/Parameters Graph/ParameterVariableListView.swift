//
//  ParameterVariableListView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterVariableListView: View {
    let variables: [ParameterGraphVariable]
    let onTap: (ParameterGraphVariable) -> Void

    var body: some View {
        List(variables) { variable in
            Button {
                onTap(variable)
            } label: {
                HStack {
                    if variable.isSelected {
                        Label(variable.type.name, systemImage: "checkmark.circle.fill")
                    } else {
                        Label(variable.type.name, systemImage: "circle")
                    }

                    Spacer()

                    Text(variable.type.unit)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ParameterVariableListView(
        variables: RawVariable.previewList().map { ParameterGraphVariable($0, isSelected: [true, false].randomElement()!) },
        onTap: { _ in }
    )
}
