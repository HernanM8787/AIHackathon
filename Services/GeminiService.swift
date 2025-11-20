import Foundation

struct GeminiPart: Codable {
    let text: String?
    let inlineData: InlineData?
    
    init(text: String? = nil, inlineData: InlineData? = nil) {
        self.text = text
        self.inlineData = inlineData
    }
}

struct InlineData: Codable {
    let mimeType: String
    let data: String
}

struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiGenerateRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiGenerateResponse: Codable {
    struct Candidate: Codable {
        let content: GeminiContent?
    }

    let candidates: [Candidate]?
}

struct GeminiAPIErrorResponse: Codable {
    struct APIError: Codable {
        let message: String
    }

    let error: APIError
}

enum GeminiServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case api(message: String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key is missing. Update GeminiConfig.apiKey."
        case .invalidURL:
            return "Failed to build Gemini API URL."
        case let .api(message):
            return message
        case .emptyResponse:
            return "Gemini returned an empty response."
        }
    }
}

final class GeminiService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func sendChat(messages: [ChatMessage], profile: UserProfile) async throws -> String {
        guard GeminiConfig.apiKey.isEmpty == false,
              GeminiConfig.apiKey != "PASTE_GEMINI_API_KEY_HERE" else {
            throw GeminiServiceError.missingAPIKey
        }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(GeminiConfig.model):generateContent?key=\(GeminiConfig.apiKey)") else {
            throw GeminiServiceError.invalidURL
        }

        let contents = buildContents(from: messages, profile: profile)
        let requestBody = GeminiGenerateRequest(contents: contents)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            if let apiError = try? JSONDecoder().decode(GeminiAPIErrorResponse.self, from: data) {
                throw GeminiServiceError.api(message: apiError.error.message)
            }
            throw GeminiServiceError.api(message: "Gemini call failed with status code \(http.statusCode).")
        }

        let decoded = try JSONDecoder().decode(GeminiGenerateResponse.self, from: data)
        // Collect all text parts from the response
        let replyText = decoded.candidates?
            .compactMap { candidate -> String? in
                candidate.content?.parts
                    .compactMap { $0.text }
                    .joined(separator: " ")
            }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !replyText.isEmpty else {
            throw GeminiServiceError.emptyResponse
        }

        return replyText
    }

    private func buildContents(from messages: [ChatMessage], profile: UserProfile) -> [GeminiContent] {
        var contents: [GeminiContent] = []

        let screenTime = String(format: "%.1f", profile.metrics.screenTimeHours)
        let context = """
        You are a supportive college well-being companion. Reference the user's data when helpful.
        Student metrics:
        - Screen time: \(screenTime) hours
        - Resting heart rate: \(profile.metrics.restingHeartRate) bpm
        - Classes: \(profile.classes.joined(separator: ", "))
        Provide concise, actionable suggestions (bullets or short paragraphs).
        """

        contents.append(
            GeminiContent(role: "user", parts: [GeminiPart(text: context)])
        )

        for message in messages {
            let role = message.role == .user ? "user" : "model"
            var parts: [GeminiPart] = []
            
            // Add image if present
            if let imageData = message.imageData {
                // Determine MIME type from image data
                let mimeType = detectMimeType(from: imageData)
                let base64String = imageData.base64EncodedString()
                parts.append(GeminiPart(inlineData: InlineData(mimeType: mimeType, data: base64String)))
            }
            
            // Add text if present
            if !message.text.isEmpty {
                parts.append(GeminiPart(text: message.text))
            }
            
            if !parts.isEmpty {
                contents.append(GeminiContent(role: role, parts: parts))
            }
        }

        return contents
    }
    
    private func detectMimeType(from data: Data) -> String {
        // Check for common image formats
        guard data.count >= 4 else { return "image/jpeg" }
        
        var bytes = [UInt8](repeating: 0, count: min(12, data.count))
        data.copyBytes(to: &bytes, count: bytes.count)
        
        // PNG: 89 50 4E 47
        if bytes.count >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
            return "image/png"
        }
        
        // JPEG: FF D8 FF
        if bytes.count >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
            return "image/jpeg"
        }
        
        // GIF: 47 49 46 38
        if bytes.count >= 4 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38 {
            return "image/gif"
        }
        
        // WEBP: Check for "RIFF" and "WEBP"
        if bytes.count >= 12 {
            let riffBytes = Array(bytes[0..<4])
            let webpBytes = Array(bytes[8..<12])
            if let riffString = String(bytes: riffBytes, encoding: .ascii),
               let webpString = String(bytes: webpBytes, encoding: .ascii),
               riffString == "RIFF" && webpString == "WEBP" {
                return "image/webp"
            }
        }
        
        // Default to JPEG
        return "image/jpeg"
    }
}
