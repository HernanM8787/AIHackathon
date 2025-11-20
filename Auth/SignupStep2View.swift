import SwiftUI

struct SignupStep2View: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var academicLevel: String = "Undergraduate"
    @State private var major: String = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    // These should be passed from step 1
    let email: String
    let password: String
    
    private let academicLevels = ["Undergraduate", "Graduate", "Doctoral", "Postdoctoral"]
    
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
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("2/2")
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
                                .frame(width: geometry.size.width, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal)
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("Tell us about you")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("This helps us personalize your experience.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                }
                .padding(.bottom, 40)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Academic Level Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Academic Level")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
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
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
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
                        
                        // Major Field (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Major (Optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("", text: $major, prompt: Text("e.g., Computer Science").foregroundColor(.white.opacity(0.5)))
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
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: completeSignup) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
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
                .disabled(isSubmitting)
                .opacity(isSubmitting ? 0.6 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .alert("Welcome to your journey!", isPresented: $showSuccessAlert) {
            Button("Get Started") {
                // User will be automatically navigated to dashboard via authStep change
            }
        } message: {
            Text("Enjoy your journey to a balanced student life.")
        }
    }
    
    private func completeSignup() {
        isSubmitting = true
        
        // Generate username from email (use part before @)
        let username = email.components(separatedBy: "@").first ?? "user"
        
        Task {
            do {
                try await appState.signUp(
                    email: email,
                    password: password,
                    username: username,
                    academicLevel: academicLevel,
                    major: major.isEmpty ? nil : major
                )
                await MainActor.run {
                    isSubmitting = false
                    // Show success alert after a brief delay to ensure state is updated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSuccessAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    // Handle error - could show error alert
                }
            }
        }
    }
}

#Preview {
    SignupStep2View(email: "test@university.edu", password: "password123")
        .environmentObject(AppState())
}

