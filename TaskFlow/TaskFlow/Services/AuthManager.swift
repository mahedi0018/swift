//
//  logout changes automatically.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 27/8/26.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

@Observable
class AuthManager {
    static let shared = AuthManager()
    
    var currentUser: User?
    var isLoggedIn: Bool = false
    var errorMessage: String?
    var isLoading: Bool = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        observeAuthState()
    }
    
    // MARK: - Listen to login/logout changes automatically
    private func observeAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isLoggedIn = (user != nil)
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                }
                // সফল হলে addStateDidChangeListener নিজে থেকেই isLoggedIn আপডেট করে দিবে
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    private func friendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail: return "Please enter a valid email address."
        case .emailAlreadyInUse: return "This email is already registered."
        case .weakPassword: return "Password should be at least 6 characters."
        case .wrongPassword: return "Incorrect password. Please try again."
        case .userNotFound: return "No account found with this email."
        case .networkError: return "Network error. Check your connection."
        default: return error.localizedDescription
        }
    }
}


extension AuthManager {
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) {
        guard let tokenData = credential.identityToken,
              let idTokenString = String(data: tokenData, encoding: .utf8) else {
            errorMessage = "Apple Sign-In failed: invalid token"
            return
        }
        
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        isLoading = true
        Auth.auth().signIn(with: firebaseCredential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var initials: String {
        guard let email = currentUser?.email, let first = email.first else {
            return "U"
        }
        return String(first).uppercased()
    }
    
    var displayName: String {
        if let name = currentUser?.displayName, !name.isEmpty {
            return name
        }
        
        
        if let email = currentUser?.email, let username = email.components(separatedBy: "@").first {
            return username.capitalized // like: "mahedijajabor001" -> "Mahedijajabor001"
        }
        
        return "TaskFlow User"
    }
    
    func reauthenticate(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthError.noUser
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        try await reauthenticate(password: currentPassword)
        try await Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
    
    func deleteAccount(password: String) async throws {
        try await reauthenticate(password: password)
        // Firebase account delete করার আগে লোকাল Realm ডেটা মুছে ফেলো —
        // কারণ delete হয়ে গেলে uid আর পাওয়া যাবে না, filter করে মোছাও যাবে না
        RealmManager.shared.deleteAllUserData()
        try await Auth.auth().currentUser?.delete()
        signOut()
    }
}

enum AuthError: LocalizedError {
    case noUser
    var errorDescription: String? {
        switch self {
        case .noUser: return "No signed-in user found."
        }
    }
}
