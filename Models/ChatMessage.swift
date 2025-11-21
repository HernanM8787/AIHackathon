import Foundation
import UIKit

struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let text: String
    let imageData: Data?
    
    init(role: Role, text: String, imageData: Data? = nil) {
        self.role = role
        self.text = text
        self.imageData = imageData
    }
}

