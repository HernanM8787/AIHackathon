import SwiftUI

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
                                    ? Color.accentColor.opacity(0.2)
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
                                        ? Color.accentColor.opacity(0.2)
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.yellow)
                            Text("AI Feedback")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        Text(feedback)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
                
                // Submit Button
                Button(action: generateFeedback) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Get Motivational Feedback")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        ((reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMood == nil && selectedInfluences.isEmpty) || isGenerating)
                        ? Color.gray
                        : Color.accentColor,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .foregroundStyle(.white)
                }
                .disabled((reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMood == nil && selectedInfluences.isEmpty) || isGenerating)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Daily Reflection")
        .navigationBarTitleDisplayMode(.inline)
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
                    I'm reflecting on my day and would love some supportive, motivational feedback.
                    
                    \(moodContext)\(influencesContext)\(trimmed.isEmpty ? "" : "Here's my reflection:\n\n\(trimmed)")
                    
                    Please provide warm, empathetic, and uplifting feedback. Acknowledge my feelings, highlight any positive aspects or strengths you notice, and offer encouraging words to help me move forward. Be supportive and understanding. If I mentioned specific stressors or influences, please address those thoughtfully.
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

#Preview {
    NavigationStack {
        DailyReflectionView()
            .environmentObject(AppState())
    }
}

