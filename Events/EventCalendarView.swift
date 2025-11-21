import SwiftUI

struct EventCalendarView: View {
    @Binding var selectedTab: DashboardTab
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateSheet = false
    @State private var showingCreateEvent = false
    @State private var showingCreateAssignment = false
    @State private var showingSearch = false
    @State private var showingSuggestionsList = false
    @State private var showingDismissedSuggestion = false
    @State private var selectedDate = Date()
    @State private var eventsForSelectedDate: [Event] = []
    @State private var assignmentsForSelectedDate: [Assignment] = []
    @State private var detailTab: CalendarDetailTab = .events
    
    private let calendar = Calendar.current
    private enum CalendarDetailTab: String, CaseIterable {
        case events = "Events"
        case assignments = "Assignments"
    }
    
    @ViewBuilder
    private var detailSection: some View {
        switch detailTab {
        case .events:
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(
                    title: "Events",
                    actionTitle: "New Event",
                    action: { showingCreateEvent = true }
                )
                
                if eventsForSelectedDate.isEmpty {
                    Text("No events scheduled for this day.")
                        .font(.caption)
                        .foregroundStyle(Theme.subtitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 14) {
                        ForEach(eventsForSelectedDate) { event in
                            EventCard(event: event)
                        }
                    }
                }
            }
        case .assignments:
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(
                    title: "Assignments",
                    actionTitle: "Add Assignment",
                    action: { showingCreateAssignment = true }
                )
                
                Text("Assignments added here can also create Apple Reminders when you toggle the reminder option.")
                    .font(.caption)
                    .foregroundStyle(Theme.subtitle)
                
                if assignmentsForSelectedDate.isEmpty {
                    Text("No assignments due on this day.")
                        .font(.caption)
                        .foregroundStyle(Theme.subtitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 12) {
                        ForEach(assignmentsForSelectedDate) { assignment in
                            AssignmentRowCard(assignment: assignment)
                        }
                    }
                }
            }
        }
    }
    
    private func sectionHeader(title: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.subtitle)
            Spacer()
            Button(action: action) {
                Label(actionTitle, systemImage: "plus")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Theme.accent.opacity(0.2))
                    )
            }
        }
    }
    
    init(selectedTab: Binding<DashboardTab>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if appState.permissionState.calendarGranted {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        calendarHeader
                        MonthCalendarView(
                            events: appState.deviceCalendarEvents,
                            selectedDate: $selectedDate,
                            onSearchTap: { showingSearch = true }
                        )
                        .padding(.top)
                        .onChange(of: selectedDate) { _, _ in
                            loadEventsForDate(selectedDate)
                            loadAssignmentsForDate(selectedDate)
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text(selectedDateHeader)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Picker("Detail", selection: $detailTab) {
                                ForEach(CalendarDetailTab.allCases, id: \.self) { tab in
                                    Text(tab.rawValue).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            // Hourly Itinerary
                            HourlyItineraryView(
                                date: selectedDate,
                                events: eventsForSelectedDate,
                                assignments: assignmentsForSelectedDate
                            )
                            .environmentObject(appState)
                            
                            // AI Suggestion Card
                            if !showingDismissedSuggestion {
                                CalendarSuggestionCard(
                                    title: "AI Suggestion: Study Break",
                                    message: "You've been studying hard. A 15-minute stretch session can boost your focus. Try some simple neck and shoulder stretches.",
                                    onStart: {
                                        startGuidedActivity(
                                            title: "15-Minute Stretch Session",
                                            description: "Simple neck and shoulder stretches to boost focus."
                                        )
                                    },
                                    onDismiss: {
                                        showingDismissedSuggestion = true
                                    }
                                )
                                
                                Button(action: { showingSuggestionsList = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                        Text("Browse more AI suggestions")
                                            .font(.footnote)
                                    }
                                    .foregroundStyle(Theme.accent)
                                }
                            }
                            
                            detailSection
                            
                            if eventsForSelectedDate.isEmpty && assignmentsForSelectedDate.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.largeTitle)
                                        .foregroundStyle(Theme.subtitle)
                                    Text("No events or assignments on \(formattedDate(selectedDate))")
                                        .foregroundStyle(Theme.subtitle)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 90)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.subtitle)
                    Text("Calendar access is not linked. Enable it from Permissions to sync events.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.subtitle)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            VStack {
                Spacer()
                Menu {
                    Button(action: { showingCreateEvent = true }) {
                        Label("New Event", systemImage: "calendar")
                    }
                    Button(action: { showingCreateAssignment = true }) {
                        Label("New Assignment", systemImage: "checklist")
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.headline)
                        Text("Add")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Theme.accentGradient)
                            .shadow(color: Theme.accent.opacity(0.35), radius: 10, y: 6)
                    )
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingCreateEvent) {
            NavigationStack {
                CreateEventView(initialDate: selectedDate)
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingCreateAssignment) {
            NavigationStack {
                AddAssignmentView(initialDate: selectedDate)
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingSearch) {
            NavigationStack {
                CalendarSearchView()
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingSuggestionsList) {
            NavigationStack {
                AISuggestionsListView { suggestion in
                    startGuidedActivity(title: suggestion.title, description: suggestion.description)
                }
                .environmentObject(appState)
            }
        }
        .onAppear {
            loadEventsForDate(selectedDate)
            loadAssignmentsForDate(selectedDate)
        }
        .onChange(of: appState.deviceCalendarEvents) { _, _ in
            loadEventsForDate(selectedDate)
        }
        .onChange(of: appState.assignments) { _, _ in
            loadAssignmentsForDate(selectedDate)
        }
        .refreshable {
            await appState.refreshCalendarEvents()
            await appState.refreshAssignments()
            loadEventsForDate(selectedDate)
            loadAssignmentsForDate(selectedDate)
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            Text("Calendar")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal)
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
        eventsForSelectedDate = appState.deviceCalendarEvents.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func loadAssignmentsForDate(_ date: Date) {
        assignmentsForSelectedDate = appState.assignments.filter { assignment in
            calendar.isDate(assignment.dueDate, inSameDayAs: date)
        }.sorted { $0.dueDate < $1.dueDate }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func startGuidedActivity(title: String, description: String) {
        let prompt = """
        The student just selected the activity "\(title)" described as "\(description)". Ask them if they are ready to begin, then guide them step-by-step in a friendly tone.
        """
        appState.pendingAssistantPrompt = prompt
        selectedTab = .assistant
        dismiss()
    }
}

// MARK: - Assignment Row Card
struct AssignmentRowCard: View {
    let assignment: Assignment
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(assignment.isCompleted ? Color.green.opacity(0.8) : Theme.accent)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Text(assignment.course)
                        .font(.caption)
                        .foregroundStyle(Theme.subtitle)
                    
                    if !assignment.course.isEmpty {
                        Text("•")
                            .foregroundStyle(Theme.subtitle)
                    }
                    
                    Text(formatTime(assignment.dueDate))
                        .font(.caption)
                        .foregroundStyle(Theme.subtitle)
                }
            }
            
            Spacer()
            
            if assignment.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.outline, lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
