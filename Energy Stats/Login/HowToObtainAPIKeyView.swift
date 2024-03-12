//
//  HowToObtainAPIKeyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2024.
//

import SwiftUI

struct HowToObtainAPIKeyView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("To get your API key:")
                .padding(.bottom, 8)

            Text("1. Login at https://www.foxesscloud.com/")
            Text("2. Click the person icon top-right")
            Text("3. Click the User Profile menu option")
            Text("4. Click API management")
            Text("5. Click Generate API key")
            Text("6. Copy the API key (make a note of it securely)")
            Text("7. Paste the API key above")
            Text("8. Your API key will be 36 characters long and look something like ") + Text("abcde123-4567-8901-2345-6789abcdef01").foregroundColor(Color.red).font(.caption)

            Text("api_key_change_reason_2")
                .font(.caption2)
                .padding(.top)

            Text("api_key_change_reason")
                .font(.caption2)
                .padding(.top)
        }
    }
}

#Preview {
    HowToObtainAPIKeyView()
}
