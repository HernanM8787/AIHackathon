import SwiftUI

struct SignupStep1View: View {
    @EnvironmentObject private var appState: AppState
    @Binding var email: String
    @Binding var password: String
    @State private var showPassword = false
    @State private var errorMessage: String?
    @State private var selectedInstitution: USInstitution? = nil
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
                        // School Selection Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Your Institution")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Menu {
                                ForEach(USInstitution.allInstitutions, id: \.domain) { institution in
                                    Button(action: {
                                        selectedInstitution = institution
                                        // Don't auto-fill email, let user type
                                    }) {
                                        HStack {
                                            Text(institution.name)
                                            if institution.domain == "kennesaw.edu" || 
                                               institution.domain == "gsu.edu" || 
                                               institution.domain == "uga.edu" {
                                                Text("(Demo)")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let selected = selectedInstitution {
                                        SchoolLogoView(school: SchoolBranding.detectSchool(from: selected.domain), size: 24)
                                        Text(selected.name)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("Choose your school...")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.system(size: 12))
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
                        }
                        
                        // Student Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Student Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                                
                                TextField("", text: $email, prompt: Text("Enter your school email").foregroundColor(.white.opacity(0.5)))
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
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
                            .onChange(of: selectedInstitution) { _, _ in
                                // Don't auto-fill, just let user type from start
                            }
                            
                            // School Detection Preview
                            if !email.isEmpty && email.contains("@") {
                                let detectedSchool = SchoolBranding.detectSchool(from: email)
                                if detectedSchool != .defaultSchool {
                                    HStack(spacing: 8) {
                                        SchoolLogoView(school: detectedSchool, size: 24)
                                        Text("Detected: \(detectedSchool.name)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(detectedSchool.primaryColor)
                                    }
                                    .padding(.top, 4)
                                } else if let selected = selectedInstitution {
                                    let school = SchoolBranding.detectSchool(from: selected.domain)
                                    if school == .defaultSchool {
                                        Text("Note: This school is not in the demo. Only KSU, GSU, and UGA are supported.")
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundColor(.orange.opacity(0.8))
                                            .padding(.top, 4)
                                    }
                                }
                            }
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
                        
                        // Password requirements
                        VStack(alignment: .leading, spacing: 6) {
                            PasswordRequirement(
                                text: "At least 8 characters long",
                                isValid: password.count >= 8
                            )
                            PasswordRequirement(
                                text: "Include a special character (!@#$%^&*)",
                                isValid: hasSpecialCharacter(password)
                            )
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
        email.contains("@") && email.contains(".") && 
        password.count >= 8 && hasSpecialCharacter(password)
    }
    
    private func hasSpecialCharacter(_ password: String) -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?/~`")
        return password.rangeOfCharacter(from: specialCharacters) != nil
    }
    
    private func proceedToStep2() {
        guard canProceed else {
            if password.count < 8 {
                errorMessage = "Password must be at least 8 characters long."
            } else if !hasSpecialCharacter(password) {
                errorMessage = "Password must include at least one special character (!@#$%^&*)."
            } else {
                errorMessage = "Please enter a valid email and password."
            }
            return
        }
        
        errorMessage = nil
        onNext()
    }
}

struct PasswordRequirement: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? Color(red: 0x42/255.0, green: 0x85/255.0, blue: 0xF4/255.0) : .white.opacity(0.3))
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
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

