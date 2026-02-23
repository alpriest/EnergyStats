//
//  ReadOnlySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/02/2026.
//

import Energy_Stats_Core
import SwiftUI

struct ReadOnlySettingsView: View {
    @StateObject private var viewModel: ReadOnlySettingsViewModel
    @FocusState private var isPasscodeFocused: Bool

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ReadOnlySettingsViewModel(configManager: configManager))
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                if viewModel.isReadOnly {
                    Text("Inverter and battery changes are prevented.")
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    Text("Inverter and battery changes are permitted.")
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: viewModel.isReadOnly)
            .frame(minWidth: 0, maxWidth: .infinity)

            Spacer()

            VStack(spacing: 20) {
                if viewModel.isReadOnly {
                    Text("Enter current passcode")
                        .font(.title2.weight(.semibold))

                    Text("Enter your 4-digit passcode to **turn off** read-only mode.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Choose a passcode")
                        .font(.title2.weight(.semibold))

                    Text("Enter a 4-digit passcode to **turn on** read-only mode.")
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

            Spacer()

            Text("If you forget your passcode, you can log out and in again.")
                .font(.caption)
        }
        .padding()
        .alert(alertContent: $viewModel.alertContent)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 0) {
                    Text("Read Only Mode:")
                        .padding(.trailing, 6)

                    if viewModel.isReadOnly {
                        dot.foregroundStyle(Color.linesNegative)
                            .accessibilityHidden(true)
                        Text("On")
                    } else {
                        dot.foregroundStyle(Color.linesPositive)
                            .accessibilityHidden(true)
                        Text("Off")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isPasscodeFocused = true
        }
    }

    private var dot: some View {
        Circle()
            .frame(width: 10, height: 10)
            .padding(.trailing, 6)
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
    NavigationView {
        ReadOnlySettingsView(configManager: ConfigManager.preview())
    }
}
