//
//  LoginView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 27/8/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showResetAlert = false
    @State private var resetEmail = ""
    @State private var resetSuccessMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("TaskFlow")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.textPrimary)
                
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                
                VStack(spacing: 14) {
                    TextField("Email", text: $email)
#if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
#endif
                        .padding()
                        .background(Color.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 20)
                
                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.danger)
                }
                
                Button {
                    authManager.signIn(email: email, password: password)
                } label: {
                    if authManager.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                
                Button("Forgot Password?") {
                    showResetAlert = true
                }
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            // nonce security-এর জন্য দরকার, production এ generate করে রাখা উচিত
                            AuthManager.shared.signInWithApple(credential: credential, nonce: "temp-nonce")
                        }
                    case .failure(let error):
                        AuthManager.shared.errorMessage = error.localizedDescription
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Button {
                    showSignUp = true
                } label: {
                    Text("Don't have an account? Sign Up")
                        .font(.caption)
                        .foregroundStyle(Color.accentSecondary)
                }
                
                Spacer()
            }
            .alert("Reset Password", isPresented: $showResetAlert) {
                TextField("Email", text: $resetEmail)
//                    .textInputAutocapitalization(.never)
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Link") {
                    AuthManager.shared.resetPassword(email: resetEmail) { success in
                        resetSuccessMessage = success ? "Reset link sent! Check your email." : nil
                    }
                }
            } message: {
                Text("Enter your email to receive a password reset link")
            }
            .padding(24)
            .background(Color.bgPrimary.ignoresSafeArea())
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
