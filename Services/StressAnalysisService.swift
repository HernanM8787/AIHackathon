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

