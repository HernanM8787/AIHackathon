import SwiftUI

struct HourlyItineraryView: View {
    @EnvironmentObject private var appState: AppState
    let date: Date
    let events: [Event]
    let assignments: [Assignment]
    
    @State private var aiSuggestions: [Int: String] = [:]
    @State private var isLoading = false
    
    private let calendar = Calendar.current
    private let hours = Array(6...23) // 6 AM to 11 PM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hourly Itinerary")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hours, id: \.self) { hour in
                        HourSlotView(
                            hour: hour,
                            date: date,
                            events: eventsForHour(hour),
                            assignments: assignmentsForHour(hour),
                            aiSuggestion: aiSuggestions[hour]
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .task {
            await generateAISuggestions()
        }
    }
    
    private func eventsForHour(_ hour: Int) -> [Event] {
        guard let hourStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date),
              let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) else {
            return []
        }
        return events.filter { event in
            event.startDate < hourEnd && event.endDate > hourStart
        }
    }
    
    private func assignmentsForHour(_ hour: Int) -> [Assignment] {
        assignments.filter { assignment in
            let assignmentHour = calendar.component(.hour, from: assignment.dueDate)
            return assignmentHour == hour
        }
    }
    
    private func generateAISuggestions() async {
        isLoading = true
        
        // Only generate suggestions for a few key hours, not all hours
        let keyHours = [9, 12, 15, 18, 21] // Morning, lunch, afternoon, evening, night
        
        // Build context about the day's schedule
        let eventsText = events.isEmpty ? "No events scheduled" : events.map { "\(formatTime($0.startDate)): \($0.title)" }.joined(separator: ", ")
        let assignmentsText = assignments.isEmpty ? "No assignments due" : assignments.map { "\(formatTime($0.dueDate)): \($0.title)" }.joined(separator: ", ")
        
        for hour in keyHours {
            let hourEvents = eventsForHour(hour)
            let hourAssignments = assignmentsForHour(hour)
            
            // Skip if hour is already filled
            if !hourEvents.isEmpty || !hourAssignments.isEmpty {
                continue
            }
            
            // Use fallback suggestions for now (can be enhanced with AI later)
            await MainActor.run {
                aiSuggestions[hour] = fallbackSuggestion(for: hour)
            }
        }
        
        isLoading = false
    }
    
    private func fallbackSuggestion(for hour: Int) -> String {
        switch hour {
        case 6...8:
            return "Start your day with a healthy breakfast and light exercise"
        case 9...11:
            return "Focus on your most important tasks while energy is high"
        case 12...13:
            return "Take a lunch break and get some fresh air"
        case 14...16:
            return "Review your notes and prepare for upcoming classes"
        case 17...19:
            return "Take a study break and connect with friends"
        case 20...23:
            return "Wind down with a relaxing activity before bed"
        default:
            return "Plan your day and prioritize your tasks"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

struct HourSlotView: View {
    let hour: Int
    let date: Date
    let events: [Event]
    let assignments: [Assignment]
    let aiSuggestion: String?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hour label
            Text(formatHour(hour))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Events
                ForEach(events.prefix(2)) { event in
                    EventMiniCard(event: event)
                }
                
                // Assignments
                ForEach(assignments.prefix(2)) { assignment in
                    AssignmentMiniCard(assignment: assignment)
                }
                
                // AI Suggestion
                if events.isEmpty && assignments.isEmpty, let suggestion = aiSuggestion {
                    AISuggestionMiniCard(suggestion: suggestion)
                }
                
                // Empty state
                if events.isEmpty && assignments.isEmpty && aiSuggestion == nil {
                    Text("Free")
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(width: 140)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.15))
        )
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

struct EventMiniCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(event.category.itineraryColor)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(formatTime(event.startDate))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AssignmentMiniCard: View {
    let assignment: Assignment
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(assignment.isCompleted ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(assignment.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(formatTime(assignment.dueDate))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AISuggestionMiniCard: View {
    let suggestion: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.caption2)
                .foregroundStyle(.yellow)
            
            Text(suggestion)
                .font(.caption2)
                .foregroundStyle(.gray)
                .lineLimit(2)
        }
    }
}

// MARK: - EventCategory Color Extension (if not already defined)
extension EventCategory {
    var itineraryColor: Color {
        switch self {
        case .academic:
            return .pink
        case .selfCare:
            return .purple
        case .social:
            return .blue
        case .fitness:
            return .green
        case .other:
            return .gray
        }
    }
}

