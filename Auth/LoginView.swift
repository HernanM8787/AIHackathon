import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                Text("Welcome back")
                    .font(.title.bold())
                Text("Sign in with your email and password.")
                    .foregroundStyle(.secondary)
            }

            Group {
                LabeledField(title: "Email") {
                    TextField("you@school.edu", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                LabeledField(title: "Password") {
                    SecureField("Password", text: $password)
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
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(!canSubmit || isSubmitting)

            Button("Need an account? Sign up") {
                appState.showSignup()
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
    }

    private var canSubmit: Bool {
        email.contains("@") && password.isEmpty == false
    }

    private func submit() {
        guard canSubmit else {
            errorMessage = "Enter your email and password."
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
    LoginView()
        .environmentObject(AppState())
}

