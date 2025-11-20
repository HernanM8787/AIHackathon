import Foundation
import SwiftUI

enum RSVPStatus: String, Codable, CaseIterable {
    case going, notGoing, undecided
}

enum EventCategory: String, Codable, CaseIterable {
    case academic = "Academic"
    case selfCare = "Self-care"
    case social = "Social"
    case fitness = "Fitness"
    case other = "Other"
    
    var color: Color {
        switch self {
        case .academic: return .pink
        case .selfCare: return .purple
        case .social: return .blue
        case .fitness: return .green
        case .other: return .gray
        }
    }
}

struct Event: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var location: String
    var startDate: Date
    var endDate: Date
    var description: String
    var rsvp: RSVPStatus
    var category: EventCategory = .other
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}
