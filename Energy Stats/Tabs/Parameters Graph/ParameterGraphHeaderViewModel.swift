//
//  ParameterGraphHeaderViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/07/2023.
//

import SwiftUI

class ParameterGraphHeaderViewModel: ObservableObject {
    @Published var hours: Int = 24 {
        didSet {
            updateDisplayMode()
        }
    }

    @Binding private var displayMode: GraphDisplayMode
    @Published var candidateQueryDate = Date() {
        didSet {
            updateDisplayMode()
        }
    }

    @Published var canChangeHours: Bool = true
    @Published var canIncrease = false

    private var isInitialised = false

    init(displayMode: Binding<GraphDisplayMode>) {
        self._displayMode = displayMode
        self.candidateQueryDate = displayMode.wrappedValue.date
        self.hours = displayMode.wrappedValue.hours

        self.isInitialised = true
    }

    func decrease() {
        hours = 24
        candidateQueryDate = candidateQueryDate.addingTimeInterval(-86400)
    }

    func increase() {
        hours = 24
        candidateQueryDate = candidateQueryDate.addingTimeInterval(86400)
    }

    func updateDisplayMode() {
        guard isInitialised else { return }

        Task { @MainActor in
            displayMode = .init(date: candidateQueryDate, hours: hours)
            canChangeHours = Calendar.current.isDate(candidateQueryDate, inSameDayAs: .now)

            canIncrease = !Calendar.current.isDate(displayMode.date, inSameDayAs: Date())
        }
    }
}
