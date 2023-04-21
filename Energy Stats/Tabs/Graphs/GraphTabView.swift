//
//  GraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct GraphHeaderView: View {
    @Binding var hours: Int
    @Binding var queryDate: QueryDate
    @State private var datePickerVisible = false
    @State private var candidateQueryDate: Date = Date()

    init(hours: Binding<Int>, queryDate: Binding<QueryDate>) {
        self._hours = hours
        self._queryDate = queryDate
        candidateQueryDate = queryDate.wrappedValue.asDate() ?? Date()
    }

    var body: some View {
        HStack {
            Picker("Hours", selection: $hours) {
                Text("6h").tag(6)
                Text("12h").tag(12)
                Text("24h").tag(24)
            }.pickerStyle(.segmented)

            Image(systemName: "calendar")
                .frame(width: 44)
                .onTapGesture {
                    withAnimation {
                        datePickerVisible.toggle()
                    }
                }
        }

        if datePickerVisible {
            HStack {
                DatePicker("Choose date", selection: $candidateQueryDate, displayedComponents: .date)
                Button("Apply") {
                    queryDate = QueryDate(from: candidateQueryDate)
                    withAnimation {
                        datePickerVisible.toggle()
                    }
                }.buttonStyle(.bordered)
            }
            .transition(.opacity)
        }
    }
}

struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            OptionalView(viewModel.errorMessage) {
                Text($0)
            }

            GraphHeaderView(hours: $viewModel.hours, queryDate: $viewModel.queryDate)

            ScrollView {
                UsageGraphView(viewModel: viewModel,
                               selectedDate: $selectedDate,
                               valuesAtTime: $valuesAtTime)
                    .frame(height: 250)

                if let valuesAtTime {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture { self.valuesAtTime = nil }

                        VStack {
                            OptionalView(selectedDate) {
                                Text($0.small())
                            }

                            ForEach(valuesAtTime.values, id: \.id) { graphValue in
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    Text(graphValue.variable.title(as: .snapshot))
                                    Text(graphValue.value.kW(2))
                                        .monospacedDigit()
                                }
                            }
                        }
                    }.padding(.vertical)
                        .font(.caption)
                } else {
                    Color.clear.padding(.bottom, 44)
                }

                VStack(alignment: .leading) {
                    ForEach(viewModel.graphVariables, id: \.self) { variable in
                        HStack {
                            Button(action: { viewModel.toggle(visibilityOf: variable) }) {
                                HStack(alignment: .top) {
                                    Circle()
                                        .foregroundColor(variable.type.colour)
                                        .frame(width: 15, height: 15)
                                        .padding(.top, 5)

                                    VStack(alignment: .leading) {
                                        Text(variable.type.title(as: .total))
                                        Text(variable.type.description)
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    OptionalView(viewModel.total(of: variable.type.reportVariable)) {
                                        Text($0.kWh(2))
                                    }
                                }
                                .opacity(variable.enabled ? 1.0 : 0.5)
                            }
                            .buttonStyle(.plain)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .scrollDisabled(true)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                }.onChange(of: viewModel.graphVariables) { _ in
                    viewModel.refresh()
                }
            }
        }
        .padding()
        .task {
            await viewModel.load()
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(DemoNetworking(), configManager: PreviewConfigManager()))
            .previewDevice("iPhone 13 Mini")
    }
}
