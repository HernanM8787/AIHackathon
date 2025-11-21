import Foundation
import Combine
import CryptoKit
import UIKit

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
    @Published var permissionState: PermissionState = PermissionState() {
        didSet {
            permissionStorage.save(permissionState)
        }
    }
    @Published var events: [Event] = MockData.events
    @Published var deviceCalendarEvents: [Event] = []
    @Published var matches: [Match] = MockData.matches
    @Published var heartRateHistory: [HeartRateSample] = []
    @Published var assignments: [Assignment] = MockData.assignments
    @Published var stressSamples: [StressSample] = []

    private let permissionStorage = PermissionStorage()
    private let authService = AuthService()
    private let firebaseService = FirebaseService()
    private let calendarService = CalendarService()
    private let healthKitService = HealthKitService()
    private let stressAnalysisService = StressAnalysisService()

    init() {
        permissionState = permissionStorage.load()
        onboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
    }

    func bootstrap() async {
        guard isAuthenticated == false else { return }
        if let profile = try? await authService.restoreSession() {
            userProfile = profile
            isAuthenticated = true
            authStep = .authenticated
            await refreshAssignments()
        } else {
            authStep = .welcome
        }
    }

    func signUp(email: String, password: String, username: String, academicLevel: String? = nil, major: String? = nil) async throws {
        let profile = try await authService.createAccount(email: email, password: password, username: username, academicLevel: academicLevel, major: major)
        userProfile = profile
        isAuthenticated = true
        authStep = .authenticated
        await refreshAssignments()
    }

    func signIn(email: String, password: String) async throws {
        let profile = try await authService.signIn(email: email, password: password)
        userProfile = profile
        isAuthenticated = true
        authStep = .authenticated
        await refreshAssignments()
    }

    func refreshData() async {
        async let eventsTask = fetchEventsForCurrentUser()
        async let matchesTask = firebaseService.fetchMatches()
        async let assignmentsTask = fetchAssignmentsForCurrentUser()
        events = (try? await eventsTask) ?? MockData.events
        matches = (try? await matchesTask) ?? MockData.matches
        assignments = (try? await assignmentsTask) ?? MockData.assignments
    }

    func signOut() async {
        try? await authService.signOut()
        isAuthenticated = false
        userProfile = .mock
        deviceCalendarEvents = []
        assignments = []
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
        async let remoteEventsTask = fetchEventsForCurrentUser()
        async let deviceEventsTask = fetchDeviceEventsForToday()
        let remoteEvents = (try? await remoteEventsTask) ?? MockData.events
        let deviceEvents = await deviceEventsTask
        await MainActor.run {
            events = remoteEvents
            deviceCalendarEvents = deviceEvents
        }
    }

    func refreshAssignments() async {
        guard isAuthenticated else {
            assignments = []
            return
        }
        do {
            assignments = try await firebaseService.fetchAssignments(for: userProfile.id)
        } catch {
            print("Failed to fetch assignments: \(error)")
        }
    }
    
    func refreshStressLevels(for date: Date = Date()) async {
        guard isAuthenticated else {
            stressSamples = []
            return
        }
        do {
            let fetched = try await firebaseService.fetchStressSamples(for: userProfile.id, date: date)
                .sorted { $0.hour < $1.hour }
            await MainActor.run {
                stressSamples = fetched
            }
        } catch {
            await generateStressLevels(for: date)
        }
    }

    @discardableResult
    func requestRemindersPermission() async -> Bool {
        let granted = await calendarService.requestReminderAccess()
        permissionState.remindersGranted = granted
        return granted
    }

    @discardableResult
    func requestHealthKitPermission() async -> Bool {
        let granted = (try? await healthKitService.requestAuthorization()) ?? false
        permissionState.healthKitGranted = granted
        if granted {
            await refreshHealthData()
        }
        return granted
    }

    @discardableResult
    func requestCalendarPermission() async -> Bool {
        let granted = await calendarService.requestAccess()
        permissionState.calendarGranted = granted
        if granted {
            await refreshCalendarEvents()
        }
        return granted
    }

    func addAssignment(title: String, course: String, dueDate: Date, details: String, createReminder: Bool = false) async throws {
        let assignment = Assignment(
            id: "",
            title: title,
            course: course,
            dueDate: dueDate,
            details: details,
            isCompleted: false
        )
        try await firebaseService.save(assignment: assignment, userId: userProfile.id)
        if createReminder {
            do {
                try await calendarService.saveReminder(title: title, dueDate: dueDate, notes: details)
                permissionState.remindersGranted = true
            } catch {
                print("Failed to save reminder: \(error)")
            }
        }
        await refreshAssignments()
    }

    func setAssignment(_ assignment: Assignment, completed: Bool) async {
        guard isAuthenticated else { return }
        do {
            try await firebaseService.updateAssignmentCompletion(
                assignmentId: assignment.id,
                userId: userProfile.id,
                isCompleted: completed
            )
            await refreshAssignments()
        } catch {
            print("Failed to update assignment: \(error)")
        }
    }

    func deleteAssignment(_ assignment: Assignment) async {
        guard isAuthenticated else { return }
        do {
            try await firebaseService.deleteAssignment(
                assignmentId: assignment.id,
                userId: userProfile.id
            )
            await refreshAssignments()
        } catch {
            print("Failed to delete assignment: \(error)")
        }
    }

    func refreshHealthData() async {
        guard permissionState.healthKitGranted else { return }
        do {
            let oneHourAgo = Date().addingTimeInterval(-3600)
            let history = try await healthKitService.heartRateSamples(since: oneHourAgo)
            heartRateHistory = history
            var latestActive = history.last?.bpm
            if latestActive == nil {
                latestActive = try await healthKitService.latestHeartRate()
            }
            let fallbackResting = try await healthKitService.latestRestingHeartRate()
            if let heartRate = latestActive ?? fallbackResting {
                var updatedProfile = userProfile
                updatedProfile.metrics.restingHeartRate = heartRate
                userProfile = updatedProfile
            }
        } catch {
            print("Failed to fetch heart rate: \(error)")
        }
    }
    
    private func generateStressLevels(for date: Date) async {
        do {
            let context = StressContext(
                events: events,
                assignments: assignments,
                heartRates: heartRateHistory
            )
            let generated = try await stressAnalysisService
                .generateStressSamples(for: date, context: context, profile: userProfile)
                .sorted { $0.hour < $1.hour }
            await MainActor.run {
                stressSamples = generated
            }
            try await firebaseService.saveStressSamples(generated, userId: userProfile.id, date: date)
        } catch {
            print("Failed to generate stress levels: \(error)")
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

    private func fetchAssignmentsForCurrentUser() async throws -> [Assignment] {
        guard isAuthenticated else { return MockData.assignments }
        return try await firebaseService.fetchAssignments(for: userProfile.id)
    }

    private func fetchDeviceEventsForToday() async -> [Event] {
        guard permissionState.calendarGranted else { return [] }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        return await calendarService.fetchEvents(from: startOfDay, to: endOfDay)
    }
}

struct PermissionState: Codable {
    var remindersGranted = false
    var healthKitGranted = false
    var calendarGranted = false
}

extension AppState {
    var peerSupportAnonId: String {
        let key = "peer_support_id_\(userProfile.id)"
        if let cached = UserDefaults.standard.string(forKey: key) {
            return cached
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let raw = "\(userProfile.id)-\(deviceID)"
        let hashed = SHA256.hash(data: Data(raw.utf8)).map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(hashed, forKey: key)
        return hashed
    }
}
