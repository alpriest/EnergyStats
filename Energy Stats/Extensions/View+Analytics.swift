//
//  View+Analytics.swift
//  Energy Stats
//
//  Created by Alistair Priest on 17/11/2024.
//

import FirebaseAnalytics
import SwiftUI

enum ScreenName: String {
    case editSchedule = "Edit Schedule"
    case batteryChargeLevel = "Battery Charge Levels"
    case batteryChargeSchedule = "Battery Charge Schedule"
    case batteryHeatingSchedule = "Battery Heating Schedule"
    case battery = "Battery"
    case dataLogger = "Datalogger"
    case settings = "Settings"
    case financialModel = "Financial Model"
    case solarPrediction = "Solar Prediction"
    case powerStation = "Power Station"
    case parameters = "Parameters"
    case powerFlowTab = "Power Flow Tab"
    case statsTab = "Stats Tab"
    case parametersTab = "Parameters Tab"
    case inverter = "Inverter"
    case summary = "Summary"
    case selfSufficiencyEstimates = "Self sufficiency estimates"
    case faq = "Frequently Asked Questions"
    case debug = "Debug"
    case data = "Data"
    case apiKey = "API Key"
    case sunDisplayVariationThresholds = "Sun display variation thresholds"
    case templates = "Templates"
    case workSchedule = "Work Schedule"
    case editPhase = "Edit phase"
    case peakShaving = "Peak Shaving"
    case pvOutput = "PVOutput"
    case readOnlyMode = "Read Only Mode"

    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}

struct AnalyticsNavigationTitleViewModifier: ViewModifier {
    let navigationTitle: String
    let analyticsTitle: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(navigationTitle)
            .analyticsScreen(name: analyticsTitle)
    }
}

extension View {
    func navigationTitle(_ type: ScreenName) -> some View {
        modifier(AnalyticsNavigationTitleViewModifier(
            navigationTitle: type.localized,
            analyticsTitle: type.rawValue
        ))
    }

    func analyticsScreen(_ type: ScreenName) -> some View {
        analyticsScreen(name: type.rawValue)
    }
}
