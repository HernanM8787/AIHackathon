import Foundation

struct GeminiPart: Codable {
    let text: String
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
        guard let reply = decoded.candidates?
            .compactMap({ $0.content?.parts.first?.text })
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              reply.isEmpty == false else {
            throw GeminiServiceError.emptyResponse
        }

        return reply
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
            contents.append(GeminiContent(role: role, parts: [GeminiPart(text: message.text)]))
        }

        return contents
    }
}
