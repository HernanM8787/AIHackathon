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
        async let eventsTask = firebaseService.fetchEvents()
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

    func showSignup() {
        authStep = .signup
    }

    func showLogin() {
        authStep = .login
    }
}

struct PermissionState {
    var screenTimeGranted = false
    var healthKitGranted = false
    var calendarGranted = false
}
