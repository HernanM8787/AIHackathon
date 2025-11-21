import Foundation

struct StressForecast: Identifiable, Codable {
    let dateKey: String
    let emoji: String
    let summary: String
    
    var id: String { dateKey }
}

