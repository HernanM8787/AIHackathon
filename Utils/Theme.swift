import SwiftUI

enum Theme {
    static let background = Color(red: 6/255, green: 6/255, blue: 8/255)
    static let surface = Color(red: 17/255, green: 17/255, blue: 23/255)
    static let card = Color(red: 27/255, green: 27/255, blue: 37/255)
    static let outline = Color.white.opacity(0.08)
    
    static let accent = Color(red: 168/255, green: 120/255, blue: 255/255)
    static let accentSecondary = Color(red: 125/255, green: 94/255, blue: 255/255)
    
    static let subtitle = Color.white.opacity(0.6)
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

