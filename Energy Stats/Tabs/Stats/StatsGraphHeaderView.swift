//
//  StatsDatePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct StatsGraphHeaderView: View {
    @ObservedObject var viewModel: StatsDatePickerViewModel
    @Binding var showingGraph: Bool
    @State private var showingCustomRangePicker = false

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
                    viewModel.range = .custom(.now.addingTimeInterval(0 - (86400 * 30)), .now, .days)
                } label: {
                    Label("Custom range", systemImage: viewModel.range.isCustom ? "checkmark" : "")
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
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(Color.primary)
            }
            .accessibilityLabel("accessibility.stats.timeperiodpicker")
            .accessibilityIdentifier("stats_datepicker")

            title()

            if viewModel.range.isCustom == false {
                incrementDecrementButtons()
            }
        }
        .sheet(isPresented: $showingCustomRangePicker) {
            CustomDateRangePickerView(
                start: viewModel.customStartDate,
                end: viewModel.customEndDate,
                displayUnit: viewModel.customDateRangeDisplayUnit,
                onUpdate: { _, _, _ in
                    showingCustomRangePicker.toggle()
                },
                onCancel: {
                    showingCustomRangePicker.toggle()
                }
            )
        }
    }

    @ViewBuilder
    private func title() -> some View {
        HStack {
            switch viewModel.range {
            case .day:
                DatePicker("Choose date", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .id("day_\(viewModel.date)")
                    .labelsHidden()
                    .accessibilityLabel("accessibility.stats.datepicker.day")
            case .month:
                HStack {
                    Menu {
                        Picker("Month", selection: $viewModel.month) {
                            ForEach(Array(Calendar.current.monthSymbols.enumerated()), id: \.element) { index, text in
                                Text(text).tag(index)
                            }
                        }
                    } label: {
                        HStack {
                            Text(Calendar.current.shortMonthSymbols[viewModel.month])
                                .frame(minWidth: 35)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote)
                        }
                    }
                    .accessibilityLabel("Month picker")
                    .accessibilityValue(Calendar.current.monthSymbols[viewModel.month])
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
                        HStack {
                            Text("\(String(describing: viewModel.year))")
                                .frame(minWidth: 30)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote)
                        }
                    }
                    .accessibilityLabel("Year picker")
                    .accessibilityValue(String(viewModel.year))
                    .onChange(of: viewModel.year) { _ in
                        viewModel.updateDisplayMode()
                    }
                }
            case .year:
                Menu {
                    Picker("Year", selection: $viewModel.year) {
                        ForEach(Array(viewModel.yearRange.reversed()), id: \.self) {
                            Text(String(describing: $0))
                        }
                    }
                } label: {
                    HStack {
                        Text("\(String(describing: viewModel.year))")
                            .frame(minWidth: 30)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                    }
                }
                .accessibilityLabel("Year picker")
                .accessibilityValue(String(viewModel.year))
                .onChange(of: viewModel.year) { _ in
                    viewModel.updateDisplayMode()
                }
            case .custom:
                customDateRangeTitle()
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
                .foregroundStyle(Color.primary)
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canDecrease)
        .accessibilityLabel(viewModel.decreaseAccessibilityLabel())

        Button {
            viewModel.increase()
        } label: {
            Image(systemName: "chevron.right")
                .frame(minWidth: 22)
                .foregroundStyle(Color.primary)
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canIncrease)
        .accessibilityLabel(viewModel.increaseAccessibilityLabel())
    }

    @ViewBuilder
    private func customDateRangeTitle() -> some View {
        HStack {
            Spacer()
            Text(viewModel.customStartDate, format: dayMonthFormat)
            Image(systemName: "arrow.right")
            Text(viewModel.customEndDate, format: dayMonthFormat)
            Spacer()

            Button {
                showingCustomRangePicker = true
            } label: {
                Text("Change")
            }
        }
    }
}

#Preview {
    StatsGraphHeaderView(viewModel: StatsDatePickerViewModel(.constant(.custom(.now, .now, .days))), showingGraph: .constant(true))
        .frame(height: 200)
}
