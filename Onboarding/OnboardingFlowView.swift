import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep = 0

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeView()
                .tag(0)
            PermissionRequestView()
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    private func completeOnboarding() {
        withAnimation {
            appState.markOnboardingComplete()
        }
    }
}

private struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Student Well-being")
                .font(.largeTitle.bold())
            Text("Grant permissions and personalize your study + wellness plan.")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
