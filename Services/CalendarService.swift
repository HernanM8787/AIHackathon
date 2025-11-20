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
                rsvp: .undecided,
                category: .other
            )
        }
    }
    
    /// Save an event to the user's iOS Calendar
    func saveEventToDeviceCalendar(_ event: Event) async throws {
        // Request access if not already granted
        let hasAccess = await requestAccess()
        guard hasAccess else {
            throw CalendarError.accessDenied
        }
        
        // Get or create the default calendar
        let calendar = store.defaultCalendarForNewEvents ?? store.calendars(for: .event).first
        
        guard let calendar = calendar else {
            throw CalendarError.noCalendarAvailable
        }
        
        // Create EKEvent
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.calendar = calendar
        ekEvent.title = event.title
        ekEvent.location = event.location
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.notes = event.description
        ekEvent.isAllDay = false
        
        // Save the event
        do {
            try store.save(ekEvent, span: .thisEvent, commit: true)
        } catch {
            throw CalendarError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Delete an event from the user's iOS Calendar
    func deleteEventFromDeviceCalendar(eventId: String) async throws {
        guard let ekEvent = store.event(withIdentifier: eventId) else {
            throw CalendarError.eventNotFound
        }
        
        do {
            try store.remove(ekEvent, span: .thisEvent, commit: true)
        } catch {
            throw CalendarError.deleteFailed(error.localizedDescription)
        }
    }
    
    /// Fetch all events for a specific date range
    func fetchEvents(from startDate: Date, to endDate: Date) async -> [Event] {
        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let ekEvents = store.events(matching: predicate)
            .sorted(by: { $0.startDate < $1.startDate })
        
        return ekEvents.map { ekEvent in
            Event(
                id: ekEvent.eventIdentifier ?? UUID().uuidString,
                title: ekEvent.title,
                location: ekEvent.location ?? "No location",
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                description: ekEvent.notes ?? "",
                rsvp: .undecided,
                category: .other
            )
        }
    }
}

enum CalendarError: LocalizedError {
    case accessDenied
    case noCalendarAvailable
    case saveFailed(String)
    case deleteFailed(String)
    case eventNotFound
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access denied. Please enable calendar access in Settings."
        case .noCalendarAvailable:
            return "No calendar available. Please create a calendar in the Calendar app."
        case .saveFailed(let message):
            return "Failed to save event: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete event: \(message)"
        case .eventNotFound:
            return "Event not found in calendar."
        }
    }
}

