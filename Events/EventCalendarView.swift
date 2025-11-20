import SwiftUI

struct EventCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false
    @State private var selectedDate = Date()
    @State private var eventsForSelectedDate: [Event] = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if appState.permissionState.calendarGranted {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        MonthCalendarView(
                            events: appState.events,
                            selectedDate: $selectedDate
                        )
                        .padding(.top)
                        .onChange(of: selectedDate) { _ in
                            loadEventsForDate(selectedDate)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(selectedDateHeader)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            CalendarSuggestionCard(
                                title: "AI Suggestion: Study Break",
                                message: "You've been studying hard. A 15-minute stretch session can boost your focus. Try some simple neck and shoulder stretches."
                            )
                            
                            if !eventsForSelectedDate.isEmpty {
                                VStack(spacing: 14) {
                                    ForEach(eventsForSelectedDate) { event in
                                        EventCard(event: event)
                                    }
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray)
                                    Text("No events on \(formattedDate(selectedDate))")
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                    Text("Calendar access is not linked. Enable it from Permissions to sync events.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            VStack {
                Spacer()
                Button(action: { showingCreateSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.headline)
                        Text("New Event")
                            .font(.headline)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                    )
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Events")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingCreateSheet) {
            NavigationStack {
                CreateEventView(initialDate: selectedDate)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            loadEventsForDate(selectedDate)
        }
        .refreshable {
            await appState.refreshCalendarEvents()
            loadEventsForDate(selectedDate)
        }
    }
    
    private var selectedDateHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let base = formatter.string(from: selectedDate)
        if calendar.isDateInToday(selectedDate) {
            return "Today, \(base)"
        }
        return base
    }
    
    private func loadEventsForDate(_ date: Date) {
        eventsForSelectedDate = appState.events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
