import Foundation

struct StressContext {
    let events: [Event]
    let assignments: [Assignment]
    let heartRates: [HeartRateSample]
}

final class StressAnalysisService {
    private let gemini = GeminiService()
    
    func generateStressSamples(for date: Date, context: StressContext, profile: UserProfile) async throws -> [StressSample] {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateLabel = formatter.string(from: date)
        
        let eventsSummary = context.events
            .sorted(by: { $0.startDate < $1.startDate })
            .prefix(10)
            .map { event in
                "- \(event.title) at \(event.startDate.formatted(date: .omitted, time: .shortened)) (\(event.category.rawValue))"
            }
            .joined(separator: "\n")
        
        let assignmentsSummary = context.assignments
            .sorted(by: { $0.dueDate < $1.dueDate })
            .prefix(10)
            .map { assignment in
                "- \(assignment.title) due \(assignment.dueDate.formatted(date: .abbreviated, time: .shortened))"
            }
            .joined(separator: "\n")
        
        let heartRateSummary = context.heartRates
            .map { "\($0.bpm)" }
            .joined(separator: ", ")
        
        let prompt = """
        You are a wellness assistant. Based on the student's schedule, assignments, and heart rate readings, produce a JSON object describing hourly stress levels for the day \(dateLabel). Stress level ranges from 0 (calm) to 10 (extreme stress).
        
        Consider these factors:
        Events:
        \(eventsSummary)
        
        Assignments:
        \(assignmentsSummary)
        
        Heart rates:
        \(heartRateSummary)
        
        Output strictly in this JSON format with 24 entries (one per hour 0-23):
        {
            "samples": [
                {"hour":0,"value":2.5},
                ...
                {"hour":23,"value":1.0}
            ]
        }
        Ensure values are between 0 and 10.
        """
        
        let message = ChatMessage(role: .user, text: prompt)
        
        do {
            let response = try await gemini.sendChat(messages: [message], profile: profile)
            if let samples = try parseResponse(response) {
                return samples
            }
        } catch {
            // fall back below
        }
        
        return fallbackSamples(context: context)
    }
    
    private func parseResponse(_ response: String) throws -> [StressSample]? {
        struct ResponseDTO: Decodable {
            struct SampleDTO: Decodable {
                let hour: Int
                let value: Double
            }
            let samples: [SampleDTO]
        }
        
        guard let data = response.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        if let dto = try? decoder.decode(ResponseDTO.self, from: data) {
            return dto.samples.map { StressSample(hour: max(0, min(23, $0.hour)), value: max(0, min(10, $0.value))) }
        }
        return nil
    }
    
    private func fallbackSamples(context: StressContext) -> [StressSample] {
        var samples: [StressSample] = []
        let calendar = Calendar.current
        let eventsByHour = Dictionary(grouping: context.events, by: { calendar.component(.hour, from: $0.startDate) })
        let assignmentsByHour = Dictionary(grouping: context.assignments, by: { calendar.component(.hour, from: $0.dueDate) })
        let heartRateAvg = context.heartRates.map(\.bpm).average()
        
        for hour in 0..<24 {
            let eventWeight = Double(eventsByHour[hour]?.count ?? 0) * 1.5
            let assignmentWeight = Double(assignmentsByHour[hour]?.count ?? 0) * 1.2
            let heartWeight: Double
            if let hr = context.heartRates.first(where: { calendar.component(.hour, from: $0.date) == hour })?.bpm {
                heartWeight = Double(max(0, hr - 70)) / 10.0
            } else {
                heartWeight = Double(max(0, Int(heartRateAvg) - 70)) / 12.0
            }
            
            let base = 2.0
            let value = min(10, base + eventWeight + assignmentWeight + heartWeight)
            samples.append(StressSample(hour: hour, value: value))
        }
        return samples
    }
}

struct StressForecastResult {
    let emoji: String
    let text: String
}

extension StressAnalysisService {
    func generateStressForecast(for date: Date, context: StressContext, profile: UserProfile) async throws -> StressForecastResult {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateLabel = formatter.string(from: date)
        
        let eventsDescription = context.events.prefix(5).map { event in
            "\(event.title) at \(event.startDate.formatted(date: .omitted, time: .shortened))"
        }.joined(separator: "\n")
        
        let assignmentsDescription = context.assignments.prefix(5).map { assignment in
            "\(assignment.title) due \(assignment.dueDate.formatted(date: .abbreviated, time: .shortened))"
        }.joined(separator: "\n")
        
        let heartSummary = context.heartRates.isEmpty ? "No heart data" : "Recent BPMs: \(context.heartRates.map { "\($0.bpm)" }.joined(separator: ", "))"
        
        let prompt = """
        You are a stress forecasting assistant. Based on today's schedule for \(dateLabel), estimate how stressful the day will feel. Respond with JSON:
        {
          "emoji": "😌",
          "summary": "2-3 sentences here"
        }
        Where emoji reflects the tone (😰 for stressful, 🙂 for calm, 😐 neutral, 😴 restful, 😬 tense, 😄 energized, etc).
        Consider events and assignments and heart rate context below:
        Events:
        \(eventsDescription)
        
        Assignments:
        \(assignmentsDescription)
        
        Heart:
        \(heartSummary)
        """
        
        let message = ChatMessage(role: .user, text: prompt)
        do {
            let response = try await gemini.sendChat(messages: [message], profile: profile)
            if let result = try parseForecast(response) {
                return result
            }
        } catch {
            // fallback below
        }
        
        let stressScore = fallbackStressScore(context: context)
        switch stressScore {
        case 7...10:
            return StressForecastResult(emoji: "😰", text: "Today looks intense. Pace yourself and take breathers between obligations.")
        case 4..<7:
            return StressForecastResult(emoji: "😐", text: "A mixed day ahead. Stay organized and you'll handle the pressure.")
        default:
            return StressForecastResult(emoji: "😄", text: "Light commitments today—perfect for catching up calmly.")
        }
    }
    
    private func parseForecast(_ response: String) throws -> StressForecastResult? {
        struct DTO: Decodable {
            let emoji: String
            let summary: String
        }
        guard let data = response.data(using: .utf8) else { return nil }
        if let dto = try? JSONDecoder().decode(DTO.self, from: data) {
            return StressForecastResult(emoji: dto.emoji, text: dto.summary)
        }
        return nil
    }
    
    private func fallbackStressScore(context: StressContext) -> Double {
        let eventWeight = Double(context.events.count) * 0.6
        let assignmentWeight = Double(context.assignments.count) * 0.8
        let heartWeight = Double(max(0, context.heartRates.map(\.bpm).average() - 70)) / 6.0
        return min(10, 2 + eventWeight + assignmentWeight + heartWeight)
    }
}

private extension Collection where Element == Int {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        return Double(sum) / Double(count)
    }
}

private extension Collection where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        return sum / Double(count)
    }
}

