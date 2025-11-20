import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    enum AuthStep: Equatable {
        case login
        case signup
        case authenticated
    }

    @Published var authStep: AuthStep = .login
    @Published var isAuthenticated = false
    @Published var onboardingComplete = false
    @Published var userProfile: UserProfile = .mock
    @Published var permissionState = PermissionState()
    @Published var events: [Event] = []
    @Published var matches: [Match] = MockData.matches

    private let authService = AuthService()
    private let firebaseService = FirebaseService()
    private let calendarService = CalendarService()
    private let healthKitService = HealthKitService()

    func bootstrap() async {
        guard isAuthenticated == false else { return }
        if let profile = try? await authService.restoreSession() {
            userProfile = profile
            isAuthenticated = true
            authStep = .authenticated
            await refreshCalendarEvents()
            await refreshHealthData()
        } else {
            authStep = .login
        }
        onboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
    }

    func signUp(email: String, password: String, username: String) async throws {
        let profile = try await authService.createAccount(email: email, password: password, username: username)
        userProfile = profile
        isAuthenticated = true
        authStep = .authenticated
    }

    func signIn(email: String, password: String) async throws {
        let profile = try await authService.signIn(email: email, password: password)
        userProfile = profile
        isAuthenticated = true
        authStep = .authenticated
    }

    func refreshData() async {
        async let matchesTask = firebaseService.fetchMatches()
        matches = (try? await matchesTask) ?? MockData.matches
        await refreshCalendarEvents()
        await refreshHealthData()
    }

    func signOut() async {
        try? await authService.signOut()
        isAuthenticated = false
        onboardingComplete = false
        UserDefaults.standard.set(false, forKey: "onboarding_complete")
        userProfile = .mock
        authStep = .login
        events = []
    }

    func refreshCalendarEvents() async {
        guard permissionState.calendarGranted else {
            events = []
            return
        }
        events = await calendarService.fetchUpcomingEvents()
    }

    func refreshHealthData() async {
        guard permissionState.healthKitGranted else { return }
        if let rate = try? await healthKitService.latestRestingHeartRate() {
            userProfile.metrics.restingHeartRate = rate ?? userProfile.metrics.restingHeartRate
        }
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        try await authService.updateProfile(profile)
        userProfile = profile
    }

    func showSignup() {
        authStep = .signup
    }
    func showLogin() {
        authStep = .login
    }

    func markOnboardingComplete() {
        onboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }
}

struct PermissionState {
    var screenTimeGranted = false
    var healthKitGranted = false
    var calendarGranted = false
}
