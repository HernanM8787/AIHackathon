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
    
    // MARK: - Posts
    
    /// Fetch all posts (or filtered by category)
    func fetchPosts(category: PostCategory? = nil) async throws -> [Post] {
        let snapshot: QuerySnapshot
        
        if let category = category, category != .all {
            snapshot = try await db.collection("posts")
                .whereField("category", isEqualTo: category.rawValue)
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
        } else {
            snapshot = try await db.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
        }
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestorePost.self).toPost(id: doc.documentID)
        }
    }
    
    /// Create a new post
    func createPost(post: Post) async throws {
        let firestorePost = FirestorePost(from: post)
        let data = try firestorePost.toDictionary()
        
        let docRef = db.collection("posts").document()
        try await docRef.setData(data)
    }
    
    /// Update post care count
    func updatePostCare(postId: String, increment: Int) async throws {
        let docRef = db.collection("posts").document(postId)
        try await docRef.updateData([
            "careCount": FieldValue.increment(Int64(increment)),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    /// Add a comment to a post
    func addComment(postId: String, comment: Comment) async throws {
        let firestoreComment = FirestoreComment(from: comment)
        let data = try firestoreComment.toDictionary()
        
        let commentRef = db.collection("posts").document(postId)
            .collection("comments").document()
        try await commentRef.setData(data)
        
        // Update post comment count
        let postRef = db.collection("posts").document(postId)
        try await postRef.updateData([
            "commentCount": FieldValue.increment(Int64(1)),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    /// Fetch comments for a post
    func fetchComments(for postId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreComment.self).toComment(id: doc.documentID)
        }
    }
    
    nonisolated func observePosts(onUpdate: @escaping ([Post]) -> Void) -> ListenerRegistration {
        let firestore = Firestore.firestore()
        return firestore.collection("posts")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    if let error {
                        print("Error observing posts: \(error)")
                    }
                    return
                }
                
                let posts = documents.compactMap { doc in
                    try? doc.data(as: FirestorePost.self).toPost(id: doc.documentID)
                }
                onUpdate(posts)
            }
    }
    
    nonisolated func observeComments(for postId: String, onUpdate: @escaping ([Comment]) -> Void) -> ListenerRegistration {
        let firestore = Firestore.firestore()
        return firestore.collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    if let error {
                        print("Error observing comments: \(error)")
                    }
                    return
                }
                
                let comments = documents.compactMap { doc in
                    try? doc.data(as: FirestoreComment.self).toComment(id: doc.documentID)
                }
                onUpdate(comments)
            }
    }

    // MARK: - Stress Levels

    func fetchStressSamples(for userId: String, date: Date) async throws -> [StressSample] {
        let key = Self.dayFormatter.string(from: date)
        let docRef = db.collection("users")
            .document(userId)
            .collection("stressLevels")
            .document(key)
        
        let snapshot = try await docRef.getDocument()
        guard snapshot.exists, let data = try? snapshot.data(as: FirestoreStressDay.self) else {
            throw StressDataError.notFound
        }
        return data.samples.map { $0.toSample() }
    }
    
    func saveStressSamples(_ samples: [StressSample], userId: String, date: Date) async throws {
        let key = Self.dayFormatter.string(from: date)
        let docRef = db.collection("users")
            .document(userId)
            .collection("stressLevels")
            .document(key)
        
        let firestoreSamples = samples.map { FirestoreStressSample(from: $0) }
        let payload = FirestoreStressDay(
            dateKey: key,
            samples: firestoreSamples,
            generatedAt: Timestamp(date: Date())
        )
        
        try await docRef.setData(payload.toDictionary())
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

// MARK: - Firestore Post Model

private struct FirestorePost: Codable {
    let userId: String
    let title: String
    let body: String
    let category: String
    let hashtags: [String]
    let careCount: Int
    let commentCount: Int
    let createdAt: Timestamp
    let updatedAt: Timestamp
    let userIconType: String
    
    init(from post: Post) {
        self.userId = post.userId
        self.title = post.title
        self.body = post.body
        self.category = post.category.rawValue
        self.hashtags = post.hashtags
        self.careCount = post.careCount
        self.commentCount = post.commentCount
        self.createdAt = Timestamp(date: post.createdAt)
        self.updatedAt = Timestamp(date: post.updatedAt)
        self.userIconType = post.userIconType.rawValue
    }
    
    func toPost(id: String) -> Post {
        Post(
            id: id,
            userId: userId,
            title: title,
            body: body,
            category: PostCategory(rawValue: category) ?? .other,
            hashtags: hashtags,
            careCount: careCount,
            commentCount: commentCount,
            createdAt: createdAt.dateValue(),
            updatedAt: updatedAt.dateValue(),
            userIconType: UserIconType(rawValue: userIconType) ?? .random
        )
    }
    
    func toDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}

// MARK: - Firestore Comment Model

private struct FirestoreComment: Codable {
    let postId: String
    let userId: String
    let body: String
    let careCount: Int
    let createdAt: Timestamp
    let userIconType: String
    
    init(from comment: Comment) {
        self.postId = comment.postId
        self.userId = comment.userId
        self.body = comment.body
        self.careCount = comment.careCount
        self.createdAt = Timestamp(date: comment.createdAt)
        self.userIconType = comment.userIconType.rawValue
    }
    
    func toComment(id: String) -> Comment {
        Comment(
            id: id,
            postId: postId,
            userId: userId,
            body: body,
            careCount: careCount,
            createdAt: createdAt.dateValue(),
            userIconType: UserIconType(rawValue: userIconType) ?? .random
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

enum StressDataError: Error {
    case notFound
}

private struct FirestoreStressDay: Codable {
    let dateKey: String
    let samples: [FirestoreStressSample]
    let generatedAt: Timestamp?
    
    func toDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}

private struct FirestoreStressSample: Codable {
    let hour: Int
    let value: Double
    
    init(from sample: StressSample) {
        self.hour = sample.hour
        self.value = sample.value
    }
    
    func toSample() -> StressSample {
        StressSample(hour: hour, value: value)
    }
}

extension FirebaseService {
    private static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()
}
