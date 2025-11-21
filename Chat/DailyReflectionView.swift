import SwiftUI
import Foundation

enum Mood: String, CaseIterable {
    case awful = "😢"
    case bad = "😕"
    case okay = "😐"
    case good = "🙂"
    case great = "😄"
    
    var label: String {
        switch self {
        case .awful: return "Awful"
        case .bad: return "Bad"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }
}

struct MoodInfluence: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    
    static let allInfluences: [MoodInfluence] = [
        MoodInfluence(name: "Academic Stress", icon: "graduationcap.fill"),
        MoodInfluence(name: "Study Habits", icon: "clock.fill"),
        MoodInfluence(name: "Social Pressures", icon: "person.2.fill"),
        MoodInfluence(name: "Workload", icon: "doc.text.fill"),
        MoodInfluence(name: "Sleep", icon: "moon.fill"),
        MoodInfluence(name: "Health", icon: "heart.fill"),
        MoodInfluence(name: "Relationships", icon: "person.fill"),
        MoodInfluence(name: "Financial", icon: "dollarsign.circle.fill"),
        MoodInfluence(name: "Time Management", icon: "calendar"),
        MoodInfluence(name: "Future Planning", icon: "map.fill")
    ]
}

struct DailyReflectionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedMood: Mood?
    @State private var selectedInfluences: Set<MoodInfluence> = []
    @State private var reflectionText: String = ""
    @State private var aiFeedback: String?
    @State private var isGenerating = false
    @FocusState private var isTextFocused: Bool
    private let service = GeminiService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("How are you feeling?")
                        .font(.largeTitle.bold())
                    
                    Text("Take a moment to reflect on your day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Overall Mood Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overall Mood")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Button(action: {
                                selectedMood = selectedMood == mood ? nil : mood
                            }) {
                                VStack(spacing: 8) {
                                    Text(mood.rawValue)
                                        .font(.system(size: 40))
                                    Text(mood.label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedMood == mood
                                    ? Color.accentColor.opacity(0.15)
                                    : Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMood == mood ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // What's Influencing You Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's influencing you?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MoodInfluence.allInfluences) { influence in
                                Button(action: {
                                    if selectedInfluences.contains(influence) {
                                        selectedInfluences.remove(influence)
                                    } else {
                                        selectedInfluences.insert(influence)
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: influence.icon)
                                            .font(.caption)
                                        Text(influence.name)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedInfluences.contains(influence)
                                        ? Color.accentColor.opacity(0.15)
                                        : Color(.secondarySystemBackground),
                                        in: Capsule()
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedInfluences.contains(influence) ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                    )
                                    .foregroundStyle(selectedInfluences.contains(influence) ? Color.accentColor : Color.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Reflection Text Area
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reflect on your day")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $reflectionText)
                        .frame(minHeight: 150)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if reflectionText.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("Today was challenging because...")
                                                .foregroundStyle(.secondary)
                                                .padding(.leading, 16)
                                                .padding(.top, 20)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .focused($isTextFocused)
                        .disabled(isGenerating)
                        .padding(.horizontal)
                }
                
                // AI Feedback Section
                if let feedback = aiFeedback {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.orange)
                                .font(.title3)
                            Text("AI Feedback")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(parseFeedbackWithLinks(feedback))
                                .font(.body)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.tertiarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Submit Button
                VStack(spacing: 24) {
                    Button(action: generateFeedback) {
                        HStack(spacing: 12) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                Text("Log Today's Entry")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(
                            Group {
                                if (reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMood == nil && selectedInfluences.isEmpty) || isGenerating {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray4))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(
                                            color: Color.accentColor.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                            }
                        )
                        .foregroundStyle(.white)
                        .scaleEffect(isGenerating ? 0.98 : 1.0)
                    }
                    .disabled((reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMood == nil && selectedInfluences.isEmpty) || isGenerating)
                    .buttonStyle(PressedButtonStyle())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isGenerating)
                    .padding(.horizontal, 24)
                    
                    // Extra spacing at bottom
                    Spacer(minLength: 20)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFocused = false
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Daily Reflection")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func parseFeedbackWithLinks(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Find URLs and make them clickable
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let matches = matches {
            for match in matches.reversed() {
                if let url = match.url,
                   let range = Range(match.range, in: text) {
                    if let attributedRange = Range(range, in: attributedString) {
                        attributedString[attributedRange].link = url
                        attributedString[attributedRange].foregroundColor = .blue
                    }
                }
            }
        }
        
        return attributedString
    }
    
    private func generateFeedback() {
        let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || selectedMood != nil || !selectedInfluences.isEmpty else { return }
        
        isGenerating = true
        isTextFocused = false
        aiFeedback = nil
        
        Task {
            do {
                // Build mood context
                var moodContext = ""
                if let mood = selectedMood {
                    moodContext = "Overall mood: \(mood.label) (\(mood.rawValue))\n"
                }
                
                // Build influences context
                var influencesContext = ""
                if !selectedInfluences.isEmpty {
                    let influenceNames = selectedInfluences.map { $0.name }.joined(separator: ", ")
                    influencesContext = "What's influencing me: \(influenceNames)\n"
                }
                
                // Create a message with the reflection and a prompt for motivational feedback
                let reflectionMessage = ChatMessage(
                    role: .user,
                    text: """
                    I'm reflecting on my day and need a supportive friend right now.
                    
                    \(moodContext)\(influencesContext)\(trimmed.isEmpty ? "" : "Here's my reflection:\n\n\(trimmed)")
                    
                    Please respond as a caring friend would - be warm, empathetic, and encouraging. Use emojis to make it feel friendly and approachable. Keep your response concise (5 sentences MAX). Format it like this:
                    
                    [Brief empathetic acknowledgment with emoji]
                    
                    💡 Mental Exercise: [ONE quick exercise I can do right now - like a breathing technique, gratitude practice, or mindfulness tip]
                    
                    🎧 Podcast Recommendation: [Podcast name and episode/topic] - [brief why it's relevant]. Include the full podcast link/URL if available.
                    
                    Be friendly, actionable, and supportive. I need a friend's perspective, not a long lecture.
                    """
                )
                
                let messages = [reflectionMessage]
                let feedback = try await service.sendChat(messages: messages, profile: appState.userProfile)
                
                await MainActor.run {
                    aiFeedback = feedback
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    aiFeedback = "I ran into an issue generating feedback: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }
}

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        DailyReflectionView()
            .environmentObject(AppState())
    }
}

