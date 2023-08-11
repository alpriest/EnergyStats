//
//  DataLoggersView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DataLogger: Identifiable {
    let moduleSN: String
    let moduleType: String
    let plantName: String
    let version: String
    let signal: Int
    let communication: Int

    var id: String { moduleSN }
}

class DataLoggersViewModel: ObservableObject {
    @Published var items: [DataLogger] = []
    @Published var state: LoadState = .inactive
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            state = .active(String(key: .loading))

            do {
                let result = try await networking.fetchDataLoggers()
                self.items = result.data.map {
                    DataLogger(moduleSN: $0.moduleSN, moduleType: $0.moduleType, plantName: $0.plantName, version: $0.version, signal: $0.signal, communication: $0.communication)
                }

                state = .inactive
            } catch {
                state = .error(error, "Could not load dataloggers")
            }
        }
    }
}

struct SignalView: View {
    let amount: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            Rectangle()
                .frame(width: 5, height: 5)
                .foregroundColor(amount > 0 ? .primary : .gray)

            Rectangle()
                .frame(width: 5, height: 10)
                .foregroundColor(amount > 1 ? .primary : .gray)

            Rectangle()
                .frame(width: 5, height: 15)
                .foregroundColor(amount > 2 ? .primary : .gray)

            Rectangle()
                .frame(width: 5, height: 20)
                .foregroundColor(amount > 3 ? .primary : .gray)
        }
    }
}

struct DataLoggerView: View {
    let item: DataLogger

    var body: some View {
        Section {
            ESLabeledText("Module SN", value: item.moduleSN)
            ESLabeledText("Module Type", value: item.moduleType)
            ESLabeledText("Plant Name", value: item.plantName)
            ESLabeledText("Version", value: item.version)
            ESLabeledContent("Signal") {
                SignalView(amount: item.signal)
            }
            ESLabeledContent("Status") {
                if item.communication == 0 {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                } else if item.communication == 1 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct DataLoggersView: View {
    @StateObject private var viewModel: DataLoggersViewModel

    init(networking: Networking) {
        self._viewModel = StateObject(wrappedValue: DataLoggersViewModel(networking: networking))
    }

    var body: some View {
        Form {
            List(viewModel.items) {
                DataLoggerView(item: $0)
            }
        }.task {
            viewModel.load()
        }.navigationTitle("Datalogger")
    }
}

struct DataLoggersView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DataLoggerView(
                item: DataLogger(
                    moduleSN: "669W2EFF22FA815",
                    moduleType: "W2",
                    plantName: "Alistair Priest",
                    version: "3.08",
                    signal: 3,
                    communication: 1
                )
            )
        }
    }
}
