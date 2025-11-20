import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @State private var showErrorAlert = false
    
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
                            
                            Image(systemName: "figure.mind.and.body")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(red: 0x42/255.0, green: 0x85/255.0, blue: 0xF4/255.0))
                        }
                        
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Log in to continue your journey.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 40)
                    
                    // Input Fields Section
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
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    
                    // Error Message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    
                    // Login Button
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
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
