import SwiftUI

struct SignupStep1View: View {
    @EnvironmentObject private var appState: AppState
    @Binding var email: String
    @Binding var password: String
    @State private var showPassword = false
    @State private var errorMessage: String?
    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0x12/255.0, green: 0x12/255.0, blue: 0x12/255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            appState.showWelcome()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("1/2")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(red: 99/255.0, green: 102/255.0, blue: 241/255.0))
                                .frame(width: geometry.size.width * 0.5, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal)
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("Create Your Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Start your journey to a balanced student life.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                }
                .padding(.bottom, 40)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Student Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Student Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                                
                                TextField("", text: $email, prompt: Text("university.email@edu.com").foregroundColor(.white.opacity(0.5)))
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .foregroundColor(.white)
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
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                                
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
                        
                        // Password requirement
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0x42/255.0, green: 0x85/255.0, blue: 0xF4/255.0))
                                .font(.system(size: 14))
                            Text("Must be at least 8 characters long.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, -8)
                        
                        // Error message
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Sign Up Button
                Button(action: proceedToStep2) {
                    Text("Sign Up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0x6B/255.0, green: 0x46/255.0, blue: 0xC8/255.0))
                        )
                }
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.6)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var canProceed: Bool {
        email.contains("@") && email.contains(".") && password.count >= 8
    }
    
    private func proceedToStep2() {
        guard canProceed else {
            errorMessage = "Please enter a valid email and password (at least 8 characters)."
            return
        }
        
        errorMessage = nil
        onNext()
    }
}

#Preview {
    SignupStep1View(
        email: .constant(""),
        password: .constant(""),
        onNext: {}
    )
    .environmentObject(AppState())
}

