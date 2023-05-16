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
                }

                Button {
                    viewModel.range = .month
                } label: {
                    Label("Month", systemImage: viewModel.range == .month ? "checkmark" : "")
                }

                Button {
                    viewModel.range = .year
                } label: {
                    Label("Year", systemImage: viewModel.range == .year ? "checkmark" : "")
                }
            } label: {
                Button {} label: {
                    Image(systemName: "calendar.badge.clock")
                }
                .buttonStyle(.bordered)
            }

            HStack {
                switch viewModel.range {
                case .day:
                    DatePicker("Choose date", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                case .month:
                    HStack {
                        Picker("Month", selection: $viewModel.month) {
                            ForEach(Array(Calendar.current.monthSymbols.enumerated()), id: \.element) { index, text in
                                Text(text).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.month) { _ in
                            viewModel.updateDisplayMode()
                        }

                        Picker("Year", selection: $viewModel.year) {
                            ForEach(Array((1990 ..< 2024).reversed()), id: \.self) {
                                Text(String(describing: $0))
                            }
                        }
                        .pickerStyle(.menu)
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
            }.buttonStyle(.bordered)

            Button {
                viewModel.increase()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: 22)
            }.buttonStyle(.bordered)
        }
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DatePickerViewModel(.constant(.day(.now)))
        DatePickerView(viewModel: model)
    }
}
