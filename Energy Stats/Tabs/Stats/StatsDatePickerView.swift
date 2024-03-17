//
//  StatsDatePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import SwiftUI

struct StatsDatePickerView: View {
    @ObservedObject var viewModel: StatsDatePickerViewModel
    @Binding var showingGraph: Bool

    var body: some View {
        HStack {
            Menu {
                Button {
                    viewModel.range = .day
                } label: {
                    Label("Day", systemImage: viewModel.range == .day ? "checkmark" : "")
                        .accessibilityIdentifier("day")
                }

                Button {
                    viewModel.range = .month
                } label: {
                    Label("Month", systemImage: viewModel.range == .month ? "checkmark" : "")
                        .accessibilityIdentifier("month")
                }

                Button {
                    viewModel.range = .year
                } label: {
                    Label("Year", systemImage: viewModel.range == .year ? "checkmark" : "")
                        .accessibilityIdentifier("year")
                }

                Button {
                    viewModel.range = .custom(.now.addingTimeInterval(0 - (86400 * 30)), .now)
                } label: {
                    Label("Custom", systemImage: viewModel.range.isCustom ? "checkmark" : "")
                        .accessibilityIdentifier("custom")
                }

                Divider()

                Button {
                    showingGraph.toggle()
                } label: {
                    Label(showingGraph ? "Hide graph" : "Show graph", systemImage: "chart.bar.xaxis")
                }
                .buttonStyle(.bordered)

            } label: {
                NonFunctionalButton {
                    Image(systemName: "calendar.badge.clock")
                }
            }.accessibilityIdentifier("stats_datepicker")

            HStack {
                switch viewModel.range {
                case .day:
                    DatePicker("Choose date", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .id("day_\(viewModel.date)")
                        .labelsHidden()
                case .month:
                    HStack {
                        Menu {
                            Picker("Month", selection: $viewModel.month) {
                                ForEach(Array(Calendar.current.monthSymbols.enumerated()), id: \.element) { index, text in
                                    Text(text).tag(index)
                                }
                            }
                        } label: {
                            NonFunctionalButton {
                                Text(Calendar.current.shortMonthSymbols[viewModel.month])
                                    .frame(minWidth: 35)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.footnote)
                            }
                        }
                        .onChange(of: viewModel.month) { _ in
                            viewModel.updateDisplayMode()
                        }

                        Menu {
                            Picker("Year", selection: $viewModel.year) {
                                ForEach(Array(viewModel.yearRange.reversed()), id: \.self) {
                                    Text(String(describing: $0))
                                }
                            }
                        } label: {
                            NonFunctionalButton {
                                Text("\(String(describing: viewModel.year))")
                                    .frame(minWidth: 30)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.footnote)
                            }
                        }
                        .onChange(of: viewModel.year) { _ in
                            viewModel.updateDisplayMode()
                        }
                    }
                case .year:
                    Picker("Year", selection: $viewModel.year) {
                        ForEach(Array((2020 ... Calendar.current.component(.year, from: Date())).reversed()), id: \.self) {
                            Text(String(describing: $0))
                        }
                    }.pickerStyle(.menu)
                case .custom:
                    customDatePickers()
                }
            }

            if viewModel.range.isCustom == false {
                incrementDecrementButtons()
            }
        }
    }

    @ViewBuilder
    private func incrementDecrementButtons() -> some View {
        Spacer()

        Button {
            viewModel.decrease()
        } label: {
            Image(systemName: "chevron.left")
                .frame(minWidth: 22)
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canDecrease)

        Button {
            viewModel.increase()
        } label: {
            Image(systemName: "chevron.right")
                .frame(minWidth: 22)
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canIncrease)
    }

    @ViewBuilder
    private func customDatePickers() -> some View {
        HStack {
            DatePicker("Start", selection: $viewModel.customStartDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .id("customStart_\(viewModel.customStartDate)")

            Image(systemName: "arrow.right")

            DatePicker("End", selection: $viewModel.customEndDate, in: viewModel.customStartDate...Date(), displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .id("customEnd_\(viewModel.customEndDate)")

            Spacer()
        }
    }
}

#Preview {
    let model = StatsDatePickerViewModel(.constant(.custom(.now, .now)))

    return StatsDatePickerView(viewModel: model, showingGraph: .constant(true))
        .frame(height: 200)
        .previewDevice("iPhone SE (3rd generation)")
}
