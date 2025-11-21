import SwiftUI

struct SchoolEventsNewsCard: View {
    let school: School
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: school.logoIcon)
                    .foregroundStyle(school.primaryColor)
                    .font(.title3)
                
                Text("\(school.name) Updates")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            // Sample events/news based on school
            VStack(alignment: .leading, spacing: 10) {
                SchoolNewsItem(
                    title: getStressReliefEvent(for: school),
                    description: getEventDescription(for: school),
                    date: "This Week",
                    color: school.primaryColor
                )
                
                SchoolNewsItem(
                    title: getBeneficialNews(for: school),
                    description: getNewsDescription(for: school),
                    date: "Recent",
                    color: school.secondaryColor
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Theme.outline, lineWidth: 1)
                )
        )
    }
    
    private func getStressReliefEvent(for school: School) -> String {
        switch school {
        case .kennesawState:
            return "Wellness Wednesday: Free Yoga Session"
        case .georgiaState:
            return "Mindfulness Meditation Workshop"
        case .uga:
            return "Stress Relief Workshop: Study Break Activities"
        case .defaultSchool:
            return "Campus Wellness Event"
        }
    }
    
    private func getEventDescription(for school: School) -> String {
        switch school {
        case .kennesawState:
            return "Join us for a free yoga session to help relieve stress and improve focus."
        case .georgiaState:
            return "Learn mindfulness techniques to manage academic stress effectively."
        case .uga:
            return "Take a break from studying with fun activities and relaxation techniques."
        case .defaultSchool:
            return "Campus-wide wellness event to help students manage stress."
        }
    }
    
    private func getBeneficialNews(for school: School) -> String {
        switch school {
        case .kennesawState:
            return "New Study Spaces Available in Library"
        case .georgiaState:
            return "Extended Library Hours for Finals Week"
        case .uga:
            return "Free Tutoring Services Expanded"
        case .defaultSchool:
            return "Campus Resources Available"
        }
    }
    
    private func getNewsDescription(for school: School) -> String {
        switch school {
        case .kennesawState:
            return "Additional quiet study areas have been added to help you focus."
        case .georgiaState:
            return "Library now open until midnight to support your study schedule."
        case .uga:
            return "More tutoring sessions available for all subjects."
        case .defaultSchool:
            return "Check out new campus resources to support your academic success."
        }
    }
}

struct SchoolNewsItem: View {
    let title: String
    let description: String
    let date: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Theme.subtitle)
                    .lineLimit(2)
                
                Text(date)
                    .font(.caption2)
                    .foregroundStyle(color.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

