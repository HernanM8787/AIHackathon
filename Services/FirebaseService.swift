import Foundation
import FirebaseAuth
import FirebaseFirestore

actor FirebaseService {
    private let db = Firestore.firestore()
    
    // MARK: - Events
    
    /// Fetch all events for the current authenticated user
    func fetchEvents(for userId: String) async throws -> [Event] {
        let snapshot = try await db.collection("events")
            .whereField("userId", isEqualTo: userId)
            .order(by: "startDate", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreEvent.self).toEvent(id: doc.documentID)
        }
    }
    
    /// Fetch events within a date range for the current user
    func fetchEvents(for userId: String, from startDate: Date, to endDate: Date) async throws -> [Event] {
        let snapshot = try await db.collection("events")
            .whereField("userId", isEqualTo: userId)
            .whereField("startDate", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("startDate", isLessThanOrEqualTo: Timestamp(date: endDate))
            .order(by: "startDate", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreEvent.self).toEvent(id: doc.documentID)
        }
    }
    
    /// Save or update an event (creates new if id doesn't exist, updates if it does)
    func save(event: Event, userId: String) async throws {
        let firestoreEvent = FirestoreEvent(from: event, userId: userId)
        let data = try firestoreEvent.toDictionary()
        
        if event.id.isEmpty || !event.id.hasPrefix("firebase_") {
            // Create new event
            let docRef = db.collection("events").document()
            try await docRef.setData(data)
        } else {
            // Update existing event (remove "firebase_" prefix)
            let docId = String(event.id.dropFirst("firebase_".count))
            try await db.collection("events").document(docId).setData(data, merge: true)
        }
    }
    
    /// Delete an event
    func delete(eventId: String) async throws {
        let docId = eventId.hasPrefix("firebase_") ? String(eventId.dropFirst("firebase_".count)) : eventId
        try await db.collection("events").document(docId).delete()
    }
    
    /// Update RSVP status for an event
    func updateRSVP(eventId: String, userId: String, status: RSVPStatus) async throws {
        let docId = eventId.hasPrefix("firebase_") ? String(eventId.dropFirst("firebase_".count)) : eventId
        try await db.collection("events").document(docId)
            .collection("rsvps").document(userId).setData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }
    
    /// Create a real-time listener for user's events
    func observeEvents(for userId: String, onUpdate: @escaping ([Event]) -> Void) -> ListenerRegistration {
        return db.collection("events")
            .whereField("userId", isEqualTo: userId)
            .order(by: "startDate", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    if let error = error {
                        print("Error fetching events: \(error)")
                    }
                    return
                }
                
                let events = documents.compactMap { doc -> Event? in
                    do {
                        return try doc.data(as: FirestoreEvent.self).toEvent(id: "firebase_\(doc.documentID)")
                    } catch {
                        print("Error decoding event: \(error)")
                        return nil
                    }
                }
                
                onUpdate(events)
            }
    }
    
    // MARK: - Matches
    
    func fetchMatches() async throws -> [Match] {
        // TODO: Replace with Firestore query
        return MockData.matches
    }

    // MARK: - Assignments

    func fetchAssignments(for userId: String) async throws -> [Assignment] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("assignments")
            .order(by: "dueDate", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreAssignment.self).toAssignment(id: doc.documentID)
        }
    }

    func save(assignment: Assignment, userId: String) async throws {
        let firestoreAssignment = FirestoreAssignment(from: assignment)
        let data = try firestoreAssignment.toDictionary()
        let collection = db.collection("users").document(userId).collection("assignments")

        if assignment.id.isEmpty {
            try await collection.document().setData(data)
        } else {
            try await collection.document(assignment.id).setData(data, merge: true)
        }
    }

    func updateAssignmentCompletion(assignmentId: String, userId: String, isCompleted: Bool) async throws {
        guard !assignmentId.isEmpty else { return }
        let doc = db.collection("users").document(userId).collection("assignments").document(assignmentId)
        try await doc.setData([
            "isCompleted": isCompleted,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func deleteAssignment(assignmentId: String, userId: String) async throws {
        guard !assignmentId.isEmpty else { return }
        try await db.collection("users").document(userId)
            .collection("assignments")
            .document(assignmentId)
            .delete()
    }
}

// MARK: - Firestore Event Model

private struct FirestoreEvent: Codable {
    let userId: String
    let title: String
    let location: String
    let startDate: Timestamp
    let endDate: Timestamp
    let description: String
    let rsvp: String
    let category: String
    let createdAt: Timestamp?
    let updatedAt: Timestamp?
    
    init(from event: Event, userId: String) {
        self.userId = userId
        self.title = event.title
        self.location = event.location
        self.startDate = Timestamp(date: event.startDate)
        self.endDate = Timestamp(date: event.endDate)
        self.description = event.description
        self.rsvp = event.rsvp.rawValue
        self.category = event.category.rawValue
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
    }
    
    func toEvent(id: String) -> Event {
        Event(
            id: id,
            title: title,
            location: location,
            startDate: startDate.dateValue(),
            endDate: endDate.dateValue(),
            description: description,
            rsvp: RSVPStatus(rawValue: rsvp) ?? .undecided,
            category: EventCategory(rawValue: category) ?? .other
        )
    }
    
    func toDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}

// MARK: - Firestore Assignment Model

private struct FirestoreAssignment: Codable {
    let title: String
    let course: String
    let dueDate: Timestamp
    let details: String
    let isCompleted: Bool
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    init(from assignment: Assignment) {
        self.title = assignment.title
        self.course = assignment.course
        self.dueDate = Timestamp(date: assignment.dueDate)
        self.details = assignment.details
        self.isCompleted = assignment.isCompleted
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
    }

    func toAssignment(id: String) -> Assignment {
        Assignment(
            id: id,
            title: title,
            course: course,
            dueDate: dueDate.dateValue(),
            details: details,
            isCompleted: isCompleted
        )
    }

    func toDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}
