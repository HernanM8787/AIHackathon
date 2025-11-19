import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    var displayName: String
    var email: String
    var gymPreference: String
    var studyPreference: String
    var classes: [String]
    var preferredMeetingTimes: [DateInterval]
    var metrics: WellnessMetrics

    static let mock = UserProfile(
        id: "demo-user",
        displayName: "Taylor",
        email: "taylor@example.com",
        gymPreference: "Morning partner",
        studyPreference: "Evening focus",
        classes: ["CS101", "Math 221", "ENG 105"],
        preferredMeetingTimes: [],
        metrics: WellnessMetrics(screenTimeHours: 5.5, restingHeartRate: 68)
    )
}

struct WellnessMetrics: Codable {
    var screenTimeHours: Double
    var restingHeartRate: Int
    var calendarSummary: String?
}

extension UserProfile {
    nonisolated static func placeholder(id: String, username: String, email: String) -> UserProfile {
        UserProfile(
            id: id,
            displayName: username,
            email: email,
            gymPreference: "TBD",
            studyPreference: "TBD",
            classes: [],
            preferredMeetingTimes: [],
            metrics: WellnessMetrics(screenTimeHours: 0, restingHeartRate: 70)
        )
    }
}
