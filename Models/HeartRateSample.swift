import Foundation

struct HeartRateSample: Identifiable, Codable {
    var id: Date { date }
    let date: Date
    let bpm: Int
}

