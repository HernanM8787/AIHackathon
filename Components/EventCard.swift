import SwiftUI

struct EventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.headline)
            Text(event.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(dateRange)
                .font(.footnote)
            HStack {
                Button("I'm going") { }
                Button("I'm not") { }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var dateRange: String {
        DateHelpers.shared.rangeString(start: event.startDate, end: event.endDate)
    }
}
