import SwiftUI

struct DashboardEventCard: View {
    let event: Event
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 16) {
            // Date block
            VStack(spacing: 2) {
                Text(monthAbbreviation)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(dayNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.2))
            )
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(timeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
    
    private var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: event.startDate).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: event.startDate)
    }
    
    private var timeDescription: String {
        if calendar.isDateInTomorrow(event.startDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Tomorrow, \(formatter.string(from: event.startDate))"
        } else {
            let daysUntil = calendar.dateComponents([.day], from: Date(), to: event.startDate).day ?? 0
            if daysUntil > 0 {
                return "In \(daysUntil) day\(daysUntil == 1 ? "" : "s")"
            } else {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return formatter.string(from: event.startDate)
            }
        }
    }
}

