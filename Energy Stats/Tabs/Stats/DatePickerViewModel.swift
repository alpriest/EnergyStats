//
//  DatePickerViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import SwiftUI

enum DatePickerRange {
    case day
    case month
    case year
}

class DatePickerViewModel: ObservableObject {
    @Published var range: DatePickerRange = .day {
        didSet { updateDisplayMode() }
    }

    @Published var month = 0
    @Published var year = 0
    @Published var date = Date.now {
        didSet { updateDisplayMode() }
    }

    @MainActor @Binding var displayMode: StatsDisplayMode

    init(_ displayMode: Binding<StatsDisplayMode>) {
        _displayMode = displayMode
        year = Calendar.current.component(.year, from: .now)
        month = Calendar.current.component(.month, from: .now)

        switch displayMode.wrappedValue {
        case .day(let date):
            self.date = date
            range = .day
        case .month(let month, let year):
            self.month = month
            self.year = year
            range = .month
        case .year(let year):
            self.year = year
            range = .year
        }
    }

    func increase() {
        switch range {
        case .day:
            date = date.addingTimeInterval(86400)
        case .month:
            if month + 1 > 11 {
                month = 0
                year = year + 1
            } else {
                month = month + 1
            }
        case .year:
            year = year + 1
        }

        updateDisplayMode()
    }

    func decrease() {
        switch range {
        case .day:
            date = date.addingTimeInterval(-86400)
        case .month:
            if month - 1 < 0 {
                month = 11
                year = year - 1
            } else {
                month = month - 1
            }
        case .year:
            year = year - 1
        }

        updateDisplayMode()
    }

    func updateDisplayMode() {
        Task { @MainActor in
            let updatedDisplayMode = makeUpdatedDisplayMode()

            if updatedDisplayMode != displayMode {
                displayMode = updatedDisplayMode
            }
        }
    }

    private func makeUpdatedDisplayMode() -> StatsDisplayMode {
        switch range {
        case .day:
            return StatsDisplayMode.day(date)
        case .month:
            return StatsDisplayMode.month(month, year)
        case .year:
            return StatsDisplayMode.year(year)
        }
    }
}
