import Foundation

enum GeminiConfig {
    /// Replace this placeholder with your actual Gemini API key.
    static let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    static let model = ProcessInfo.processInfo.environment["GEMINI_MODEL"] ?? ""
}

