import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var showingChangePassword = false
    @State private var showingChangeName = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture/Logo
                        SchoolLogoView(school: appState.userProfile.school, size: 80)
                        
                        VStack(spacing: 4) {
                            Text(appState.userProfile.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(appState.userProfile.email)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            
                            SchoolBadgeView(school: appState.userProfile.school)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Account Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        // Change Display Name
                        Button(action: { showingChangeName = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Display Name")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text(appState.userProfile.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Change Password
                        Button(action: { showingChangePassword = true }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Change Password")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text("Update your account password")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Email (Read-only)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.white)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email Address")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Text(appState.userProfile.email)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.15))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // App Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        // Face ID Toggle
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundStyle(.white)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Face ID")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Text("Use Face ID to sign in")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { appState.userProfile.biometricsEnabled },
                                set: { newValue in
                                    toggleBiometrics(newValue)
                                }
                            ))
                            .tint(.purple)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.15))
                        )
                        .padding(.horizontal)
                        
                        // Notification Settings
                        NavigationLink(destination: ProfileNotificationSettingsView()) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text("Manage notification preferences")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Community Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Community")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: PeerSupportView().environmentObject(appState)) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .foregroundStyle(.purple)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Peer Support")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text("Connect with other students")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Permissions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Permissions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: PermissionRequestView()) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Manage Permissions")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text("Calendar, HealthKit, Screen Time")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Danger Zone
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        // Logout Button
                        Button(action: { showingLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundStyle(.red)
                                    .frame(width: 24)
                                Text("Sign Out")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingChangePassword) {
            NavigationStack {
                ProfileChangePasswordView()
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingChangeName) {
            NavigationStack {
                ChangeNameView()
                    .environmentObject(appState)
            }
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task {
                    await appState.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private func toggleBiometrics(_ enabled: Bool) {
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        Task {
            do {
                try await appState.updateBiometrics(enabled: enabled, deviceID: enabled ? deviceID : nil)
            } catch {
                print("Error updating biometrics: \(error)")
            }
        }
    }
}

struct ProfileChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isChanging = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Form {
                Section("Current Password") {
                    if showPassword {
                        TextField("Enter current password", text: $currentPassword)
                            .foregroundStyle(.white)
                    } else {
                        SecureField("Enter current password", text: $currentPassword)
                            .foregroundStyle(.white)
                    }
                }
                .listRowBackground(Color(white: 0.15))
                
                Section {
                    if showPassword {
                        TextField("Enter new password", text: $newPassword)
                            .foregroundStyle(.white)
                    } else {
                        SecureField("Enter new password", text: $newPassword)
                            .foregroundStyle(.white)
                    }
                    
                    if showPassword {
                        TextField("Confirm new password", text: $confirmPassword)
                            .foregroundStyle(.white)
                    } else {
                        SecureField("Confirm new password", text: $confirmPassword)
                            .foregroundStyle(.white)
                    }
                } header: {
                    Text("New Password")
                } footer: {
                    Text("Password must be at least 8 characters long.")
                        .foregroundStyle(.gray)
                }
                .listRowBackground(Color(white: 0.15))
                
                Section {
                    Toggle("Show Passwords", isOn: $showPassword)
                        .foregroundStyle(.white)
                }
                .listRowBackground(Color(white: 0.15))
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    .listRowBackground(Color(white: 0.15))
                }
                
                Section {
                    Button(action: changePassword) {
                        HStack {
                            if isChanging {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isChanging ? "Changing..." : "Change Password")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || isChanging)
                }
                .listRowBackground(Color(white: 0.15))
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        isChanging = true
        errorMessage = nil
        
        Task {
            do {
                let auth = Auth.auth()
                guard let user = auth.currentUser, let email = user.email else {
                    throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
                }
                
                // Re-authenticate with current password
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                try await user.reauthenticate(with: credential)
                
                // Update password
                try await user.updatePassword(to: newPassword)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isChanging = false
                }
            }
        }
    }
}

struct ChangeNameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var newName: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Form {
                Section {
                    TextField("Enter your name", text: $newName)
                        .foregroundStyle(.white)
                } header: {
                    Text("Display Name")
                } footer: {
                    Text("This is how your name appears in the app.")
                        .foregroundStyle(.gray)
                }
                .listRowBackground(Color(white: 0.15))
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    .listRowBackground(Color(white: 0.15))
                }
                
                Section {
                    Button(action: saveName) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isSaving ? "Saving..." : "Save")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(newName.isEmpty || isSaving)
                }
                .listRowBackground(Color(white: 0.15))
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
        }
        .navigationTitle("Change Name")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            newName = appState.userProfile.displayName
        }
    }
    
    private func saveName() {
        guard !newName.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                var updatedProfile = appState.userProfile
                updatedProfile.displayName = newName
                try await appState.updateProfile(updatedProfile)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update name: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}

struct ProfileNotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Notification Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Notification preferences coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

