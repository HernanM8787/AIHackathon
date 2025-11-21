import SwiftUI

struct MonthCalendarView: View {
    let events: [Event]
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    @State private var showingMonthPicker = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header with chevron down, search, and calendar icons
            HStack {
                Button(action: { showingMonthPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Text(dateFormatter.string(from: currentMonth))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    Button(action: {}) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        isToday: calendar.isDateInToday(date),
                        events: eventsForDate(date),
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        guard let firstDayWeekday = calendar.dateComponents([.weekday], from: firstDayOfMonth).weekday else {
            return []
        }
        
        let firstWeekday = calendar.firstWeekday
        let daysToSubtract = (firstDayWeekday - firstWeekday + 7) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDayOfMonth) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks)
        for _ in 0..<42 {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let events: [Event]
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(
                        isSelected ? .white :
                        isCurrentMonth ? .white : .gray
                    )
                
                // Colored dots for events
                if !events.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(Array(Set(events.map { $0.category })).prefix(3), id: \.self) { category in
                            Circle()
                                .fill(category.color)
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }
            .frame(width: 44, height: 50)
            .background(
                Circle()
                    .fill(isSelected ? Color(white: 0.25) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}


