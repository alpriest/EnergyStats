//
//  InverterWorkModeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterWorkModeView: View {
    @StateObject var viewModel: InverterWorkModeViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: InverterWorkModeViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    List {
                        ForEach(viewModel.items, id: \.self) { item in
                            Button {
                                viewModel.toggle(updating: item)
                            } label: {
                                HStack(alignment: .firstTextBaseline) {
                                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                    VStack(alignment: .leading) {
                                        Text(item.item.title)

                                        OptionalView(item.item.subtitle) {
                                            AnyView($0)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                footer: {
                    FindOutMoreView(urlString: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Inverter-Work-Modes")
                }
            }

            BottomButtonsView { viewModel.save() }
        }
        .loadable(viewModel.state) {
            viewModel.load()
        }
        .alert(alertContent: $viewModel.alertContent)
        .navigationTitle("Work Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView(
                networking: NetworkService.preview(),
                config: ConfigManager.preview()
            )
        }
    }
}
