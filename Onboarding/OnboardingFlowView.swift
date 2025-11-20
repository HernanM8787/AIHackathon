import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep = 0

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeView(
                onBegin: {
                    withAnimation {
                        currentStep = 1
                    }
                },
                onSignIn: {
                    withAnimation {
                        appState.showLogin()
                    }
                }
            )
            .tag(0)

            PermissionRequestView()
                .environmentObject(appState)
                .tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
    }
}

private struct WelcomeView: View {
    let onBegin: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Abstract shape placeholder
                Circle()
                    .strokeBorder(Color(white: 0.2), lineWidth: 4)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.15), Color(white: 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .frame(width: 220, height: 220)
                    .overlay(
                        Circle()
                            .stroke(Color(white: 0.05), lineWidth: 8)
                            .blur(radius: 20)
                    )
                    .padding(.top, 32)

                // AI Focus Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text("AI DAILY FOCUS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    Text("\"Embrace the quiet moments between deadlines. Your mind, like a seed, needs rest to grow.\"")
                        .font(.body)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(white: 0.12))
                )

                VStack(spacing: 12) {
                    Text("Welcome to Balance")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Your partner in navigating academic life with a calm mind.")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                VStack(spacing: 16) {
                    Button(action: onBegin) {
                        Text("Begin Your Journey")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(Color.white)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 8)
                    }

                    Button(action: onSignIn) {
                        Text("I Already Have an Account")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
    }
}
