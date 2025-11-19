import Foundation

struct Match: Identifiable, Codable {
    let id: String
    var peerName: String
    var sharedClasses: [String]
    var compatibilityScore: Double
    var overlapSummary: String
    var contactMethod: String
}
