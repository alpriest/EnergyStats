//
//  StatsDatePickerViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import SwiftUI

enum DatePickerRange: Equatable {
    case day
    case month
    case year
    case custom(_ start: Date, _ end: Date, _ unit: CustomDateRangeDisplayUnit)

    var isCustom: Bool {
        self != .day && self != .month && self != .year
    }
}

class StatsDatePickerViewModel: ObservableObject {
    @Published var range: DatePickerRange = .day {
        didSet { updateDisplayMode() }
    }

    @Published var month = 0
    @Published var year = 0 {
        didSet { updateDisplayMode() }
    }

    @Published var date = Date.now {
        didSet { updateDisplayMode() }
    }

    @Published private(set) var customStartDate = Date.now
    @Published private(set) var customEndDate = Date.now
    @Published private(set) var customDateRangeDisplayUnit: CustomDateRangeDisplayUnit = .days

    var yearRange = 2010 ... (Calendar.current.component(.year, from: .now))
    @Published var canIncrease = false
    @Published var canDecrease = true

    @MainActor @Binding var displayMode: StatsGraphDisplayMode
    private var isInitialised = false

    init(_ displayMode: Binding<StatsGraphDisplayMode>) {
        _displayMode = displayMode
        year = Calendar.current.component(.year, from: .now)
        month = Calendar.current.component(.month, from: .now) - 1

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
        case .custom(let start, let end, let unit):
            range = .custom(start, end, unit)
            customStartDate = start
            customEndDate = end
            customDateRangeDisplayUnit = unit
        }

        isInitialised = true
        updateQuickNavigationButtons(displayMode.wrappedValue)
    }
    
    func updateCustomDateRange(start: Date, end: Date, unit: CustomDateRangeDisplayUnit) {
        range = .custom(start, end, unit)
        self.customStartDate = start
        self.customEndDate = end
        self.customDateRangeDisplayUnit = unit
    }

    func increaseAccessibilityLabel() -> String {
        switch range {
        case .day:
            "accessibility.next.day"
        case .month:
            "accessibility.next.month"
        case .year:
            "accessibility.next.year"
        case .custom:
            ""
        }
    }

    func decreaseAccessibilityLabel() -> String {
        switch range {
        case .day:
            "accessibility.previous.day"
        case .month:
            "accessibility.previous.month"
        case .year:
            "accessibility.previous.year"
        case .custom:
            ""
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
        case .custom:
            ()
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
        case .custom:
            ()
        }

        updateDisplayMode()
    }

    func updateDisplayMode() {
        guard isInitialised else { return }

        Task { @MainActor in
            let updatedDisplayMode = makeUpdatedDisplayMode()

            if updatedDisplayMode != displayMode {
                displayMode = updatedDisplayMode
                updateQuickNavigationButtons(displayMode)
            }
        }
    }

    private func updateQuickNavigationButtons(_ displayMode: StatsGraphDisplayMode) {
        switch displayMode {
        case .day(let date):
            canIncrease = !Calendar.current.isDate(date, inSameDayAs: Date())
            canDecrease = true
        case .month(let month, let year):
            let currentMonth = Calendar.current.component(.month, from: Date()) - 1
            let currentYear = Calendar.current.component(.year, from: Date())
            canIncrease = (year < currentYear) || (month < currentMonth && year <= currentYear)
            canDecrease = true
        case .year(let year):
            let currentYear = Calendar.current.component(.year, from: Date())
            canIncrease = year < currentYear
            canDecrease = true
        case .custom:
            canIncrease = false
            canDecrease = false
        }
    }

    private func makeUpdatedDisplayMode() -> StatsGraphDisplayMode {
        return switch range {
        case .day:
            StatsGraphDisplayMode.day(date)
        case .month:
            StatsGraphDisplayMode.month(month, year)
        case .year:
            StatsGraphDisplayMode.year(year)
        case .custom(let start, let end, let unit):
            StatsGraphDisplayMode.custom(start, end, unit)
        }
    }
}
