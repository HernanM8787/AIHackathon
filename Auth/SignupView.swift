import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                Text("Create your account")
                    .font(.title.bold())
                Text("Use your school email, choose a unique username, and set a password.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Group {
                LabeledField(title: "Email") {
                    TextField("you@school.edu", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                LabeledField(title: "Username") {
                    TextField("campusbuddy", text: $username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                LabeledField(title: "Password") {
                    SecureField("At least 6 characters", text: $password)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button(action: submit) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign Up")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(!canSubmit || isSubmitting)

            Button("Already have an account? Sign in") {
                appState.showLogin()
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
    }

    private var canSubmit: Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedUsername.count >= 3 &&
            email.contains("@") &&
            password.count >= 6
    }

    private func submit() {
        guard canSubmit else {
            errorMessage = "Make sure email, username, and password look good."
            return
        }

        errorMessage = nil
        isSubmitting = true
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                try await appState.signUp(email: trimmedEmail, password: password, username: trimmedUsername)
                await MainActor.run {
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSubmitting = false
                }
            }
        }
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AppState())
}

