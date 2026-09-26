//
//  PrivacySecurityView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 5/9/26.
//

import SwiftUI
import FirebaseAuth
import RealmSwift

struct PrivacySecurityView: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    
    @State private var viewModel = SettingsViewModel()
    
    // শুধু form input — এগুলো pure UI state, ViewModel এ যাওয়ার দরকার নেই
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showDeleteConfirmation = false
    @State private var showDeletePasswordPrompt = false
    @State private var deletePassword = ""
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(
                    titile: "Privacy & Security",
                    subtitle: "Manage your account safety",
                    hasNotification: false
                )
                
                // MARK: - Change Password
                SettingsSectionCard(title: "Change Password") {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        SecureField("Current Password", text: $currentPassword)
                            .textContentType(.password)
                            .padding(12)
                            .background(Color.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        SecureField("New Password", text: $newPassword)
                            .textContentType(.newPassword)
                            .padding(12)
                            .background(Color.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        SecureField("Confirm New Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding(12)
                            .background(Color.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if let error = viewModel.passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color.danger)
                        }
                        
                        if viewModel.passwordSuccess {
                            Text("Password updated successfully")
                                .font(.caption)
                                .foregroundStyle(Color.success)
                        }
                        
                        Button {
                            _Concurrency.Task {
                                await viewModel.updatePassword(current: currentPassword, new: newPassword, confirm: confirmPassword)
                                if viewModel.passwordSuccess {
                                    currentPassword = ""
                                    newPassword = ""
                                    confirmPassword = ""
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isChangingPassword {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Update Password").font(.subheadline.bold())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentPrimary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(viewModel.isChangingPassword || currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Data & Privacy
                SettingsSectionCard(title: "Data & Privacy") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 14) {
                            Image(systemName: "tray.and.arrow.up.fill")
                                .font(.system(size: 18))
                                .frame(width: 40, height: 40)
                                .background(Color.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export My Data")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.textPrimary)
                                Text("Download tasks & habits as JSON")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            Spacer()
                            
                            if viewModel.isExporting {
                                ProgressView()
                            } else if let exportedFileURL = viewModel.exportedFileURL {
                                ShareLink(item: exportedFileURL) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundStyle(Color.accentPrimary)
                                }
                            } else {
                                Button(action: {
                                    _Concurrency.Task {
                                        await viewModel.exportData()
                                    }
                                }, label: {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.textSecondary)
                                })
                                
                                
                            }
                        }
                        
                        if let error = viewModel.exportError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color.danger)
                        }
                    }
                    
                    Divider()
                    
                    SettingsNavRow(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        subtitle: "How we handle your data"
                    ) {
                        showPrivacyPolicy = true
                    }
                }
                
                // MARK: - Danger Zone
                SettingsSectionCard(title: "Danger Zone") {
                    SettingsNavRow(
                        icon: "trash.fill",
                        title: "Delete Account",
                        subtitle: "Permanently erase your data",
                        isDestructive: true
                    ) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .padding(16)
            .padding(.bottom, tabBarHeight + 20)
        }
        
        .ignoresSafeArea(.container)
        .sheet(isPresented: $showPrivacyPolicy) {
            NavigationStack {
                PrivacyPolicyView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showPrivacyPolicy = false }
                        }
                    }
            }
            .presentationDetents([.large])
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showDeletePasswordPrompt = true
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
        .alert("Confirm Password", isPresented: $showDeletePasswordPrompt) {
            SecureField("Password", text: $deletePassword)
            Button("Cancel", role: .cancel) { deletePassword = "" }
            Button("Delete Forever", role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteAccount(password: deletePassword)
                    deletePassword = ""
                }
            }
        } message: {
            Text("Enter your password to confirm account deletion.")
        }
        .overlay(alignment: .bottom) {
            if let error = viewModel.deleteError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.danger, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    PrivacySecurityView()
}

