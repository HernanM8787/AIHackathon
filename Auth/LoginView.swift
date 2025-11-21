import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @State private var showErrorAlert = false
    @State private var showManualLogin = false
    @State private var hasAttemptedFaceID = false
    
    var body: some View {
        ZStack {
            // Dark charcoal background
            Color(red: 0x12/255.0, green: 0x12/255.0, blue: 0x12/255.0)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Top Section with Icon
                    VStack(spacing: 16) {
                        // Meditative person icon in rounded square
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0x20/255.0, green: 0x20/255.0, blue: 0x2A/255.0))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: showManualLogin ? "person.fill" : "faceid")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(red: 0x42/255.0, green: 0x85/255.0, blue: 0xF4/255.0))
                        }
                        
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(showManualLogin ? "Enter your credentials to log in." : "Use Face ID to securely access your account.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)
                    
                    // Face ID Section (Primary)
                    if !showManualLogin {
                        VStack(spacing: 24) {
                            // Face ID Button (Primary)
                            Button(action: authenticateWithFaceID) {
                                VStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                    Text("Sign in with Face ID")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 0x6B/255.0, green: 0x46/255.0, blue: 0xC8/255.0))
                                )
                            }
                            .disabled(isSubmitting)
                            .padding(.horizontal)
                            
                            // Manual Login Fallback
                            Button(action: {
                                showManualLogin = true
                            }) {
                                Text("Use Email & Password Instead")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    
                    // Input Fields Section (Manual Login)
                    if showManualLogin {
                        VStack(alignment: .leading, spacing: 24) {
                        // Student Email Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Student Email Address")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("", text: $email, prompt: Text("you@university.com").foregroundColor(.white.opacity(0.5)))
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x3A/255.0))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack {
                                if showPassword {
                                    TextField("", text: $password, prompt: Text("Enter your password").foregroundColor(.white.opacity(0.5)))
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.white.opacity(0.5)))
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.system(size: 16))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x3A/255.0))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            
                            HStack(spacing: 6) {
                                Image(systemName: "faceid")
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Use Face ID")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        
                            // Forgot Password Link
                            HStack {
                                Spacer()
                                Button(action: {
                                    // TODO: Implement forgot password functionality
                                }) {
                                    Text("Forgot Password?")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0x6B/255.0, green: 0x46/255.0, blue: 0xC8/255.0))
                                }
                            }
                            .padding(.top, -8)
                            
                            // Back to Face ID
                            Button(action: {
                                showManualLogin = false
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Back to Face ID")
                                }
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                    
                    // Error Message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    
                    // Login Button (Manual)
                    if showManualLogin {
                        Button(action: submit) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Login")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0x6B/255.0, green: 0x46/255.0, blue: 0xC8/255.0))
                        )
                        .disabled(isSubmitting || !canSubmit)
                        .opacity(canSubmit && !isSubmitting ? 1.0 : 0.6)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }

                        // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(action: {
                            appState.showSignup()
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0x6B/255.0, green: 0x46/255.0, blue: 0xC8/255.0))
                        }
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
        }
        .alert("Login Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                showErrorAlert = false
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            // Auto-trigger Face ID on appear if credentials exist
            if !hasAttemptedFaceID {
                hasAttemptedFaceID = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authenticateWithFaceID()
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        email.contains("@") && password.isEmpty == false
    }
    
    private func submit() {
        guard canSubmit else {
            errorMessage = "Please enter your email and password."
            return
        }
        
        errorMessage = nil
        isSubmitting = true
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        Task {
            do {
                try await appState.signIn(email: trimmedEmail, password: password)
                await MainActor.run {
                    KeychainHelper.saveCredentials(email: trimmedEmail, password: password)
                    isSubmitting = false
                }
            } catch let error as AuthError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "An unexpected error occurred. Please try again."
                    showErrorAlert = true
                    isSubmitting = false
                }
            }
        }
    }

    private func authenticateWithFaceID() {
        guard let credentials = KeychainHelper.loadCredentials() else {
            errorMessage = "Enable Face ID in Settings after signing in once."
            showErrorAlert = true
            return
        }
        
        let context = LAContext()
        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            errorMessage = authError?.localizedDescription ?? "Face ID is not available."
            showErrorAlert = true
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in with Face ID") { success, evaluateError in
            if success {
                Task { await signInWithBiometricCredentials(credentials) }
            } else if let evaluateError {
                DispatchQueue.main.async {
                    errorMessage = evaluateError.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func signInWithBiometricCredentials(_ credentials: KeychainHelper.Credentials) async {
        await MainActor.run {
            isSubmitting = true
        }
        do {
            try await appState.signIn(email: credentials.email, password: credentials.password)
            await MainActor.run {
                email = credentials.email
                if appState.userProfile.biometricsEnabled {
                    KeychainHelper.saveCredentials(email: credentials.email, password: credentials.password)
                }
                isSubmitting = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                isSubmitting = false
                KeychainHelper.deleteCredentials()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
