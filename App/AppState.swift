import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    enum AuthStep: Equatable {
        case welcome
        case login
        case signup
        case authenticated
    }

    @Published var authStep: AuthStep = .welcome
    @Published var isAuthenticated = false
    @Published var onboardingComplete = false
    @Published var userProfile: UserProfile = .mock
    @Published var permissionState = PermissionState()
    @Published var events: [Event] = MockData.events
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
        } else {
            authStep = .welcome
        }
    }

    func signUp(email: String, password: String, username: String, academicLevel: String? = nil, major: String? = nil) async throws {
        let profile = try await authService.createAccount(email: email, password: password, username: username, academicLevel: academicLevel, major: major)
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
        async let eventsTask = fetchEventsForCurrentUser()
        async let matchesTask = firebaseService.fetchMatches()
        events = (try? await eventsTask) ?? MockData.events
        matches = (try? await matchesTask) ?? MockData.matches
    }

    func signOut() async {
        try? await authService.signOut()
        isAuthenticated = false
        onboardingComplete = false
        userProfile = .mock
        authStep = .welcome
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        try await authService.updateProfile(profile)
        userProfile = profile
    }

    func updateBiometrics(enabled: Bool, deviceID: String?) async throws {
        try await authService.updateBiometrics(enabled: enabled, deviceID: deviceID)
        userProfile.biometricsEnabled = enabled
        userProfile.biometricDeviceID = deviceID
        if !enabled {
            KeychainHelper.deleteCredentials()
        }
    }

    func refreshCalendarEvents() async {
        let fetched = (try? await fetchEventsForCurrentUser()) ?? MockData.events
        await MainActor.run {
            events = fetched
        }
    }

    func refreshHealthData() async {
        guard permissionState.healthKitGranted else { return }
        do {
            if let heartRate = try await healthKitService.latestRestingHeartRate() {
                userProfile.metrics.restingHeartRate = heartRate
            }
        } catch {
            print("Failed to fetch heart rate: \(error)")
        }
    }

    func showSignup() {
        authStep = .signup
    }

    func showLogin() {
        authStep = .login
    }
    
    func showWelcome() {
        authStep = .welcome
    }

    func markOnboardingComplete() {
        onboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
        authStep = .authenticated
    }

    private func fetchEventsForCurrentUser() async throws -> [Event] {
        guard isAuthenticated else { return MockData.events }
        return try await firebaseService.fetchEvents(for: userProfile.id)
    }
}

struct PermissionState {
    var screenTimeGranted = false
    var healthKitGranted = false
    var calendarGranted = false
}
