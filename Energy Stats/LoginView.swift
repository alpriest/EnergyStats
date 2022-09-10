//
//  LoginView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    let credentials: Credentials

    var body: some View {
        VStack {
            Text("Enter your details")
                .font(.title)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            Button("Let's go") {
                credentials.username = username
                credentials.password = password
                credentials.hasCredentials = true
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }.padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(credentials: Credentials())
    }
}
