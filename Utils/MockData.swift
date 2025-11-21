import Foundation

enum MockData {
    static let events: [Event] = {
        let now = Date()
        return [
            Event(id: "event-1", title: "Study Jam", location: "Library", startDate: now, endDate: now.addingTimeInterval(3600), description: "Bring homework", rsvp: .undecided),
            Event(id: "event-2", title: "Gym meetup", location: "Rec Center", startDate: now.addingTimeInterval(7200), endDate: now.addingTimeInterval(10800), description: "Leg day", rsvp: .going)
        ]
    }()

    static let matches: [Match] = [
        Match(id: "match-1", peerName: "Alex", sharedClasses: ["CS101"], compatibilityScore: 0.82, overlapSummary: "Shared CS101, free mornings, loves gym", contactMethod: "alex@school.edu"),
        Match(id: "match-2", peerName: "Jordan", sharedClasses: ["ENG 105", "Math 221"], compatibilityScore: 0.75, overlapSummary: "Prefers evening study blocks", contactMethod: "@jordan" )
    ]

    static let assignments: [Assignment] = [
        Assignment(id: "assignment-1", title: "CS Lab Report", course: "CS101", dueDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date(), details: "Document networking experiment", isCompleted: false),
        Assignment(id: "assignment-2", title: "Essay Draft", course: "ENG105", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), details: "Draft intro + outline", isCompleted: false)
    ]
}
