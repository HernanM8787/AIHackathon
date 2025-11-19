import Foundation

actor FirebaseService {
    func fetchEvents() async throws -> [Event] {
        // TODO: Replace with Firestore query
        return MockData.events
    }

    func fetchMatches() async throws -> [Match] {
        // TODO: Replace with Firestore query
        return MockData.matches
    }

    func save(event: Event) async throws {
        // TODO: Implement create/update API
    }
}
