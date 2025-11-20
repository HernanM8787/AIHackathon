import SwiftUI
import FirebaseAuth

struct AccountInformationView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var academicLevel: String = "Undergraduate"
    @State private var major: String = ""
    @State private var email: String = ""
    @State private var biometricsEnabled: Bool = false
    @State private var isSaving = false
    @State private var showChangePassword = false
    @State private var showNotificationSettings = false
    @State private var remindersLoading = false
    @State private var healthKitLoading = false
    @State private var calendarLoading = false
    
    private let academicLevels = ["Undergraduate", "Graduate", "Doctoral", "Postdoctoral"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Account Information")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // Invisible button to balance the layout
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Academic Level
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Academic Level")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Menu {
                                ForEach(academicLevels, id: \.self) { level in
                                    Button(level) {
                                        academicLevel = level
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(academicLevel)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.3))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Major (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Major (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            TextField("", text: $major, prompt: Text("Enter your major").foregroundColor(.gray))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.3))
                                .cornerRadius(12)
                        }
                        
                        // Email Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.gray))
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.3))
                                .cornerRadius(12)
                        }
                        
                        // Change Password
                        NavigationLink(destination: ChangePasswordView()) {
                            HStack {
                                Text("Change Password")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Notification Settings + Face ID Toggle stacked
                        VStack(spacing: 12) {
                            NavigationLink(destination: NotificationSettingsView()) {
                                HStack {
                                    Text("Notification Settings")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .cornerRadius(12)
                            }
                            
                            PermissionManagementView(
                                permissionState: appState.permissionState,
                                remindersLoading: remindersLoading,
                                healthKitLoading: healthKitLoading,
                                calendarLoading: calendarLoading,
                                grantReminders: requestReminderAccess,
                                grantHealthKit: requestHealthKitAccess,
                                grantCalendar: requestCalendarAccess
                            )
                            
                            Toggle(isOn: $biometricsEnabled) {
                                Label("Use Face ID on this device", systemImage: "faceid")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .cornerRadius(12)
                            .tint(Color(red: 99/255.0, green: 102/255.0, blue: 241/255.0))
                            .onChange(of: biometricsEnabled) { _, newValue in
                                toggleBiometrics(newValue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            Task {
                                await appState.signOut()
                            }
                        }) {
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
                
                // Save Changes Button
                Button(action: saveChanges) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 99/255.0, green: 102/255.0, blue: 241/255.0))
                .cornerRadius(12)
                .padding()
                .disabled(isSaving)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        // Get email from Firebase Auth (the login credential)
        email = Auth.auth().currentUser?.email ?? appState.userProfile.email
        academicLevel = appState.userProfile.academicLevel ?? "Undergraduate"
        major = appState.userProfile.major ?? ""
        biometricsEnabled = appState.userProfile.biometricsEnabled
    }
    
    private func saveChanges() {
        isSaving = true
        Task {
            do {
                var updatedProfile = appState.userProfile
                updatedProfile.email = email
                updatedProfile.academicLevel = academicLevel
                updatedProfile.major = major.isEmpty ? nil : major
                updatedProfile.biometricsEnabled = biometricsEnabled
                try await appState.updateProfile(updatedProfile)
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    // Handle error - could show an alert here
                }
            }
        }
    }

    private func toggleBiometrics(_ enabled: Bool) {
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else {
            biometricsEnabled = false
            return
        }
        Task {
            do {
                try await appState.updateBiometrics(enabled: enabled, deviceID: enabled ? deviceID : nil)
            } catch {
                await MainActor.run {
                    biometricsEnabled.toggle()
                }
            }
        }
    }

    private func requestReminderAccess() {
        remindersLoading = true
        Task {
            await appState.requestRemindersPermission()
            await MainActor.run {
                remindersLoading = false
            }
        }
    }

    private func requestHealthKitAccess() {
        healthKitLoading = true
        Task {
            await appState.requestHealthKitPermission()
            await MainActor.run {
                healthKitLoading = false
            }
        }
    }

    private func requestCalendarAccess() {
        calendarLoading = true
        Task {
            await appState.requestCalendarPermission()
            await MainActor.run {
                calendarLoading = false
            }
        }
    }
}

private struct PermissionManagementView: View {
    let permissionState: PermissionState
    let remindersLoading: Bool
    let healthKitLoading: Bool
    let calendarLoading: Bool
    let grantReminders: () -> Void
    let grantHealthKit: () -> Void
    let grantCalendar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .foregroundColor(.white)
                .font(.subheadline.bold())
            PermissionRow(
                title: "Reminders",
                granted: permissionState.remindersGranted,
                isLoading: remindersLoading,
                action: grantReminders
            )
            PermissionRow(
                title: "HealthKit",
                granted: permissionState.healthKitGranted,
                isLoading: healthKitLoading,
                action: grantHealthKit
            )
            PermissionRow(
                title: "Calendar",
                granted: permissionState.calendarGranted,
                isLoading: calendarLoading,
                action: grantCalendar
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
        .cornerRadius(12)
    }
}

private struct PermissionRow: View {
    let title: String
    let granted: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(title) Access")
                    .foregroundColor(.white)
                Text(granted ? "Granted" : "Tap to grant access")
                    .font(.caption)
                    .foregroundColor(granted ? .green : .gray)
            }
            Spacer()
            if granted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 99/255.0, green: 102/255.0, blue: 241/255.0))
            }
        }
    }
}

// Placeholder views for navigation
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Change Password")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Password change functionality coming soon")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Notification Settings")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Notification settings coming soon")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AccountInformationView()
            .environmentObject(AppState())
    }
}

