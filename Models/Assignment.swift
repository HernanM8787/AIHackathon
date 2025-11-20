import Foundation

struct Assignment: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var course: String
    var dueDate: Date
    var details: String
    var isCompleted: Bool

    static func placeholder(id: String = UUID().uuidString) -> Assignment {
        Assignment(
            id: id,
            title: "Sample Assignment",
            course: "Course 101",
            dueDate: Date(),
            details: "Sample description",
            isCompleted: false
        )
    }
}

