import EventKit

final class CalendarService {
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            return granted
        } catch {
            return false
        }
    }

    func fetchUpcomingEvents(limit: Int = 5) async -> [Event] {
        // TODO: Map EKEvents into Event models
        return MockData.events
    }
}
