import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.authStep {
            case .login:
                LoginView()
            case .signup:
                SignupView()
            case .authenticated:
                if appState.onboardingComplete {
                    HomeDashboardView()
                } else {
                    OnboardingFlowView()
                }
            }
        }
        .animation(.easeInOut, value: appState.authStep)
        .animation(.easeInOut, value: appState.onboardingComplete)
        .task {
            await appState.bootstrap()
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(AppState())
}
