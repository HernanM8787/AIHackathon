import SwiftUI

struct AISuggestionsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    let suggestions = [
        AISuggestion(
            title: "15-Minute Stretch Session",
            description: "Simple neck and shoulder stretches to boost focus",
            duration: "15 min",
            category: .fitness
        ),
        AISuggestion(
            title: "Mindful Breathing Exercise",
            description: "Take 5 minutes to practice deep breathing for stress relief",
            duration: "5 min",
            category: .selfCare
        ),
        AISuggestion(
            title: "Quick Walk Break",
            description: "A 10-minute walk can refresh your mind and improve focus",
            duration: "10 min",
            category: .fitness
        ),
        AISuggestion(
            title: "Hydration Reminder",
            description: "Drink a glass of water to stay hydrated and maintain energy",
            duration: "2 min",
            category: .selfCare
        ),
        AISuggestion(
            title: "Review Study Notes",
            description: "Quick 10-minute review of today's key concepts",
            duration: "10 min",
            category: .academic
        ),
        AISuggestion(
            title: "Social Break",
            description: "Connect with a friend or classmate for a quick chat",
            duration: "15 min",
            category: .social
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AI Activity Suggestions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Choose an activity to help you stay balanced and focused")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                    
                    ForEach(suggestions) { suggestion in
                        SuggestionRowCard(suggestion: suggestion)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

struct AISuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let category: EventCategory
}

struct SuggestionRowCard: View {
    let suggestion: AISuggestion
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            Circle()
                .fill(suggestion.category.itineraryColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: iconForCategory(suggestion.category))
                        .foregroundStyle(suggestion.category.itineraryColor)
                        .font(.title3)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(suggestion.description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(suggestion.duration)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Start activity
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(suggestion.category.itineraryColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
    
    private func iconForCategory(_ category: EventCategory) -> String {
        switch category {
        case .academic: return "book.fill"
        case .selfCare: return "heart.fill"
        case .social: return "person.2.fill"
        case .fitness: return "figure.run"
        case .other: return "star.fill"
        }
    }
}

