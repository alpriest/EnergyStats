//
//  ReadOnlySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/02/2026.
//

import Energy_Stats_Core
import SwiftUI

class ReadOnlySettingsViewModel: ObservableObject {
    private(set) var configManager: ConfigManaging
    @Published var isReadOnly: Bool = false {
        didSet {
            configManager.isReadOnly = isReadOnly
        }
    }

    @Published var passcode: String = ""
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        self.isReadOnly = configManager.isReadOnly
    }

    func updatePasscode(_ newValue: String) {
        let filtered = String(newValue.filter { $0.isNumber }.prefix(4))

        if filtered.count == 4 {
            switch isReadOnly {
            case true:
                if filtered == configManager.readOnlyCode {
                    isReadOnly = false
                    passcode = ""
                    configManager.readOnlyCode = ""
                } else {
                    alertContent = AlertContent(title: "Failed", message: "Passcode was incorrect. Try again.")
                    passcode = ""
                }
            case false:
                configManager.readOnlyCode = filtered
                isReadOnly = true
                passcode = ""
            }
        } else {
            if filtered != passcode {
                passcode = filtered
            }
        }
    }
}

struct ReadOnlySettingsView: View {
    @StateObject private var viewModel: ReadOnlySettingsViewModel
    @FocusState private var isPasscodeFocused: Bool

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ReadOnlySettingsViewModel(configManager: configManager))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter passcode")
                .font(.title2.weight(.semibold))

            if viewModel.isReadOnly {
                Text("Enter your 4-digit passcode to **disable** read-only mode.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Enter a 4-digit passcode to **enable** read-only mode.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                TextField("", text: $viewModel.passcode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isPasscodeFocused)
                    .opacity(0.01)
                    .frame(height: 30)
                    .onChange(of: viewModel.passcode) { newValue in
                        viewModel.updatePasscode(newValue)
                    }

                HStack(spacing: 12) {
                    ForEach(0 ..< 4, id: \.self) { index in
                        PasscodeDigitView(isFilled: index < viewModel.passcode.count)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isPasscodeFocused = true
                }
            }
        }
        .alert(alertContent: $viewModel.alertContent)
        .padding()
        .onAppear {
            isPasscodeFocused = true
        }
    }
}

struct PasscodeDigitView: View {
    let isFilled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.4), lineWidth: 1)
                .frame(width: 44, height: 52)

            if isFilled {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

#Preview {
    ReadOnlySettingsView(configManager: ConfigManager.preview())
}
