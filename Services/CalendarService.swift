import EventKit

final class CalendarService {
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17, *) {
                return try await store.requestFullAccessToEvents()
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
        } catch {
            return false
        }
    }

    func fetchUpcomingEvents(limit: Int = 5) async -> [Event] {
        let calendars = store.calendars(for: .event)
        let now = Date()
        let end = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        let predicate = store.predicateForEvents(withStart: now, end: end, calendars: calendars)
        let ekEvents = store.events(matching: predicate)
            .sorted(by: { $0.startDate < $1.startDate })
            .prefix(limit)

        return ekEvents.map { ekEvent in
            Event(
                id: ekEvent.eventIdentifier ?? UUID().uuidString,
                title: ekEvent.title,
                location: ekEvent.location ?? "No location",
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                description: ekEvent.notes ?? "",
                rsvp: .undecided
            )
        }
    }
}
