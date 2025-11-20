import SwiftUI

struct EventCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false
    @State private var selectedDate = Date()
    @State private var eventsForSelectedDate: [Event] = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            if appState.permissionState.calendarGranted {
                VStack(spacing: 0) {
                    // Calendar View
                    MonthCalendarView(
                        events: appState.deviceCalendarEvents,
                        selectedDate: $selectedDate
                    )
                    .padding(.vertical)
                    .onChange(of: selectedDate) { _ in
                        loadEventsForDate(selectedDate)
                    }
                    
                    // Events List for Selected Date
                    VStack(alignment: .leading, spacing: 0) {
                        // Section Header
                        Text(selectedDateHeader)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                        
                        // Events List
                        if !eventsForSelectedDate.isEmpty {
                            List {
                                ForEach(eventsForSelectedDate) { event in
                                    EventCard(event: event)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.black)
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
            
            // Floating New Event Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingCreateSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New Event")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(white: 0.25))
                        )
                    }
                    .padding(.trailing)
                    .padding(.bottom, 20)
                }
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
        .onChange(of: appState.deviceCalendarEvents) { _ in
            loadEventsForDate(selectedDate)
        }
        .refreshable {
            await appState.refreshCalendarEvents()
            loadEventsForDate(selectedDate)
        }
    }
    
    private var selectedDateHeader: String {
        let formatter = DateFormatter()
        if calendar.isDateInToday(selectedDate) {
            formatter.dateFormat = "'Today,' MMMM d"
        } else {
            formatter.dateFormat = "MMMM d"
        }
        return formatter.string(from: selectedDate)
    }
    
    private func loadEventsForDate(_ date: Date) {
        eventsForSelectedDate = appState.deviceCalendarEvents.filter { event in
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
