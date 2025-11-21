import Foundation

struct StressSample: Identifiable, Codable {
    let hour: Int
    let value: Double
    
    var id: Int { hour }
}

