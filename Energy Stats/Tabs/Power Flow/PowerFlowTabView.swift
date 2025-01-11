//
//  PowerFlowTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct PowerFlowTabView: View {
    @StateObject private var viewModel: PowerFlowTabViewModel
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    @AppStorage("showLastUpdateTimestamp") private var showLastUpdateTimestamp: Bool = false
    private let templateStore: TemplateStoring
    private let networking: Networking

    init(
        configManager: ConfigManaging,
        networking: Networking,
        userManager: UserManager,
        appSettingsPublisher: LatestAppSettingsPublisher,
        templateStore: TemplateStoring
    ) {
        _viewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, configManager: configManager, userManager: userManager))
        self.appSettingsPublisher = appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
        self.templateStore = templateStore
        self.networking = networking
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case let .loaded(summary):
                LoadedPowerFlowView(
                    configManager: viewModel.configManager,
                    viewModel: summary,
                    appSettingsPublisher: appSettingsPublisher,
                    networking: networking,
                    templateStore: templateStore
                )

                Spacer()

                updateFooterMessage()
            case let .failed(error, reason):
                Spacer()
                ErrorAlertView(cause: error, message: reason, options: .all) {
                    Task { await viewModel.timerFired() }
                }
                Spacer()
            case .unloaded:
                Spacer()
                LoadingView(message: "Loading")
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(background().edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.viewAppeared()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
        .trackVisibility(on: viewModel)
        .navigationTitle(.powerFlowTab)
    }

    @ViewBuilder func background() -> some View {
        switch appSettings.showSunnyBackground {
        case true:
            backgroundGradient
        case false:
            Color.background
        }
    }

    @ViewBuilder func updateFooterMessage() -> some View {
        HStack {
            if appSettings.showLastUpdateTimestamp {
                lastUpdateMessage()
                updateState()
            } else {
                Group {
                    if showLastUpdateTimestamp {
                        lastUpdateMessage()
                    } else {
                        updateState()
                    }
                }.onTapGesture {
                    showLastUpdateTimestamp.toggle()
                }
            }
        }
        .monospacedDigit()
        .font(.caption)
        .foregroundColor(Color("text_dimmed"))
    }

    func updateState() -> Text {
        Text(viewModel.updateState.text)
            .accessibilityLabel(viewModel.updateState.accessibilityText)
    }

    @ViewBuilder func lastUpdateMessage() -> some View {
        Text("Last update") +
            Text(" ") +
            Text(viewModel.lastUpdated, formatter: DateFormatter.hourMinuteSecond)
    }

    private var backgroundGradient: some View {
        switch viewModel.state {
        case .loaded:
            return LinearGradient(colors: [Color("Sunny"), Color.background], startPoint: UnitPoint(x: -0.6, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.5))
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color.background], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color.background], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        }
    }
}

#if DEBUG
#Preview {
    PowerFlowTabView(configManager: ConfigManager.preview(),
                     networking: NetworkService.preview(),
                     userManager: UserManager.preview(),
                     appSettingsPublisher: CurrentValueSubject(AppSettings.mock()),
                     templateStore: TemplateStore.preview())
}
#endif
