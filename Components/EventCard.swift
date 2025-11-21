import SwiftUI

struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(event.category.color)
                .frame(width: 10, height: 10)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 6) {
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
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(event.category.color.opacity(0.4))
                    )
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.12))
        )
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}
