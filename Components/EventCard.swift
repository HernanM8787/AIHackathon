import SwiftUI

struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Colored indicator dot
            Circle()
                .fill(event.category.color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Text(timeString)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    if !event.location.isEmpty && event.location != "No location" {
                        Text("•")
                            .foregroundStyle(.gray)
                        Text(event.location)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                
                Text(event.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(event.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(event.category.color.opacity(0.15))
                    )
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}
