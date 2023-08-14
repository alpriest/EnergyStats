//
//  DatePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import SwiftUI

struct DatePickerView: View {
    @ObservedObject var viewModel: DatePickerViewModel

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
                        ForEach(Array((1990 ..< 2024).reversed()), id: \.self) {
                            Text(String(describing: $0))
                        }
                    }.pickerStyle(.menu)
                }
            }

            Spacer()

            Button {
                viewModel.decrease()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: 22)
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.increase()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: 22)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canIncrease)
        }
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DatePickerViewModel(.constant(.month(8, 2023)))

        return DatePickerView(viewModel: model)
            .previewDevice("iPhone SE (3rd generation)")
    }
}
