//
//  SignUpView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 27/8/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title2.bold())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    #endif
                    .padding()
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                SecureField("Password (min 6 characters)", text: $password)
                    .padding()
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if let error = authManager.errorMessage {
                
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.danger)
                    .onAppear{
                        print("SignUpView:", error)
                    }
            }

            Button {
                authManager.signUp(email: email, password: password)
            } label: {
                if authManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(email.isEmpty || password.count < 6 || !passwordsMatch || authManager.isLoading)

            Spacer()
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

#Preview {
    SignUpView()
        .preferredColorScheme(.dark)
}
