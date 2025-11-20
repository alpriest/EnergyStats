//
//  ConfigureAPIKeyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/01/2024.
//

import Energy_Stats_Core
import SwiftUI

struct ConfigureAPIKeyView: View {
    @EnvironmentObject var wrapper: KeychainWrapper
    @State private var apiKey: String = ""
    @State private var originalValue: String = ""
    @State private var isDirty = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField(text: $apiKey) {
                        Text("API Key")
                    }
                } footer: {
                    Text("If you need to change your API key then you can replace it above without losing your settings.")
                }
            }

            BottomButtonsView(dirty: isDirty) {
                try? wrapper.store.store(apiKey: apiKey, notifyObservers: true)
            }
        }.onAppear {
            let apiKey = (try? wrapper.store.getToken()) ?? ""
            self.originalValue = apiKey
            self.apiKey = apiKey
        }.onChange(of: apiKey) {
            isDirty = $0 != originalValue
        }.navigationTitle(.apiKey)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        ConfigureAPIKeyView()
            .environmentObject(KeychainWrapper(KeychainStore.preview()))
    }
}
#endif
