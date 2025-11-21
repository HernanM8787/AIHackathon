import Foundation

enum PostCategory: String, Codable, CaseIterable {
    case all = "All Posts"
    case academics = "Academics"
    case social = "Social"
    case health = "Health"
    case other = "Other"
}

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var title: String
    var body: String
    var category: PostCategory
    var hashtags: [String]
    var careCount: Int
    var commentCount: Int
    let createdAt: Date
    var updatedAt: Date
    
    // Anonymous user icon type (for display)
    var userIconType: UserIconType = .random
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
}

enum UserIconType: String, Codable, CaseIterable {
    case question = "questionmark"
    case people = "person.2"
    case heart = "heart"
    case star = "star"
    case circle = "circle"
    
    var systemImage: String {
        rawValue
    }
    
    static var random: UserIconType {
        allCases.randomElement() ?? .question
    }
}

struct Comment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    var body: String
    var careCount: Int
    let createdAt: Date
    var userIconType: UserIconType = .random
}

