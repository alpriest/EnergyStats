//
//  ErrorAlertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/11/2022.
//

import SwiftUI

struct ErrorAlertView: View {
    @State private var ripple = false
    let retry: () -> Void
    let details: String
    @State private var errorShowing = false

    var body: some View {
        VStack {
            VStack {
                Button(action: { errorShowing.toggle() }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: ripple ? 130 : 99, height: ripple ? 130 : 99)

                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                    }
                    .transition(.opacity.combined(with: .scale.animation(.easeOut)))
                    .animation(Animation.easeIn(duration: 0.06), value: ripple)
                    .frame(height: 130)
                    .onTapGesture {
                        errorShowing.toggle()
                    }
                }

                Text("Something went wrong. Tap icon for full detail.")
                    .padding(.bottom)

                Button(action: { retry() }) {
                    Text("retry")
                }.buttonStyle(.bordered)
            }
            .frame(height: 200)
            .alert(details, isPresented: $errorShowing) {
                Button("OK") {}
            }
            .onAppear { ripple = true }
        }
    }
}

struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorAlertView(
            retry: {},
            details: "This is a long emssages"
        )
    }
}
