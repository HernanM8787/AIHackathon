import Foundation

enum RSVPStatus: String, Codable, CaseIterable {
    case going, notGoing, undecided
}

struct Event: Identifiable, Codable {
    let id: String
    var title: String
    var location: String
    var startDate: Date
    var endDate: Date
    var description: String
    var rsvp: RSVPStatus
}
