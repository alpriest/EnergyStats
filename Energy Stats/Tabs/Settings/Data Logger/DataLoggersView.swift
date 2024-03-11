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
    let stationID: String
    let online: Bool
    let signal: Int

    var id: String { moduleSN }
}

class DataLoggersViewModel: ObservableObject, HasLoadState {
    @Published var items: [DataLogger] = []
    @Published var state: LoadState = .inactive
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            setState(.active("Loading"))

            do {
                let result = try await networking.fetchDataLoggers()
                self.items = result.map {
                    DataLogger(
                        moduleSN: $0.moduleSN,
                        stationID: $0.stationID,
                        online: $0.status == .online,
                        signal: $0.signal
                    )
                }

                setState(.inactive)
            } catch {
                setState(.error(error, "Could not load dataloggers"))
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
                .foregroundColor(amount > 0 ? .primary : .paleGray)

            Rectangle()
                .frame(width: 5, height: 10)
                .foregroundColor(amount > 1 ? .primary : .paleGray)

            Rectangle()
                .frame(width: 5, height: 15)
                .foregroundColor(amount > 2 ? .primary : .paleGray)

            Rectangle()
                .frame(width: 5, height: 20)
                .foregroundColor(amount > 3 ? .primary : .paleGray)
        }
    }
}

struct DataLoggerView: View {
    let item: DataLogger

    var body: some View {
        Section {
            ESLabeledText("Module SN", value: item.moduleSN)
            ESLabeledText("Station ID", value: item.stationID)
            ESLabeledContent("Signal") {
                SignalView(amount: item.signal)
            }
            ESLabeledContent("Status") {
                if item.online {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
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
        }
        .navigationTitle("Datalogger")
    }
}

#Preview {
    Form {
        DataLoggerView(
            item: DataLogger(
                moduleSN: "669W2EFF22FA815",
                stationID: "W2",
                online: true,
                signal: 3
            )
        )
    }
}
