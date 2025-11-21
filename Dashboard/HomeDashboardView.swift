import SwiftUI
import Combine
import Charts

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: DashboardTab = .dashboard
    @State private var isHeartRateLoading = false
    private let heartRateRefreshInterval: TimeInterval = 300
    @State private var heartRateTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    @State private var showingAddAssignment = false

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .dashboard:
                    dashboard
                case .stats:
                    statsView
                case .add:
                    addView
                case .calendar:
                    calendarView
                case .gemini:
                    geminiView
                case .profile:
                    profileView
                }
            }
            
            VStack {
                Spacer()
                BottomTabBar(selected: $selectedTab)
                    .padding(.bottom, 8)
            }
        }
        .task(id: appState.permissionState.healthKitGranted) {
            await refreshHeartRateIfNeeded()
        }
        .task(id: appState.permissionState.calendarGranted) {
            if appState.permissionState.calendarGranted {
                await appState.refreshCalendarEvents()
            }
        }
        .sheet(isPresented: $showingAddAssignment) {
            AddAssignmentView()
                .environmentObject(appState)
        }
        .onReceive(heartRateTimer) { _ in
            Task {
                await refreshHeartRateIfNeeded()
            }
        }
    }
    
    private var statsView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Stats View")
                .foregroundStyle(.white)
        }
    }
    
    private var addView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Add View")
                .foregroundStyle(.white)
        }
    }
    
    private var calendarView: some View {
        NavigationStack {
            EventCalendarView()
                .environmentObject(appState)
        }
    }
    
    private var geminiView: some View {
        NavigationStack {
            VirtualAssistantView()
                .environmentObject(appState)
        }
    }
    
    private var profileView: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(appState)
        }
    }

    private var dashboard: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with profile and welcome
                    HStack(spacing: 12) {
                        // School logo/profile picture
                        SchoolLogoView(school: appState.userProfile.school, size: 50)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Text(appState.userProfile.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            SchoolBadgeView(school: appState.userProfile.school)
                        }
                        
                        Spacer()
                        
                        // Bell icon
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Mental State Card
                    MentalStateCard()
                        .padding(.horizontal)
                    
                    // AI Insight Card
                    AIInsightCard(
                        insight: "Your mood is stable, but your upcoming PSY-201 exam might be a stressor. Prioritizing study breaks could improve focus and wellbeing."
                    )
                    .padding(.horizontal)
                    
                    // Activity Cards (side by side)
                    HStack(spacing: 12) {
                        ActivityCard(
                            title: "Study Activity",
                            value: "4.5 hours",
                            icon: "book.fill",
                            progress: nil
                        )
                        
                        ActivityCard(
                            title: "Screen Time",
                            value: formatScreenTime(appState.userProfile.metrics.screenTimeHours),
                            icon: "iphone",
                            progress: min(appState.userProfile.metrics.screenTimeHours / 10.0, 1.0)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Upcoming Events Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Events")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        if appState.permissionState.calendarGranted {
                            if appState.deviceCalendarEvents.isEmpty {
                                Text("No upcoming events in your calendar.")
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(Array(appState.deviceCalendarEvents.prefix(5))) { event in
                                    DashboardEventCard(event: event)
                                        .padding(.horizontal)
                                }
                            }
                        } else {
                            Text("Calendar Not Linked")
                                .foregroundStyle(.gray)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Peer Support Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Peer Support")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: PeerSupportView().environmentObject(appState)) {
                            HStack(spacing: 16) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.title2)
                                    .foregroundStyle(.purple)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color.purple.opacity(0.2))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Connect with Peers")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("Share experiences and get support")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(white: 0.15))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 90) // Space for bottom tab bar
                }
            }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func formatScreenTime(_ hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }
}

extension HomeDashboardView {
    private var heartRateDisplayText: String {
        guard appState.permissionState.healthKitGranted else {
            return "Not Linked"
        }
        return isHeartRateLoading ? "Loading..." : "\(appState.userProfile.metrics.restingHeartRate) bpm"
    }

    private var assignmentsDueToday: [Assignment] {
        let calendar = Calendar.current
        return appState.assignments
            .filter { calendar.isDate($0.dueDate, inSameDayAs: Date()) }
            .sorted(by: { $0.dueDate < $1.dueDate })
    }

    private func refreshHeartRateIfNeeded(force: Bool = false) async {
        guard appState.permissionState.healthKitGranted else { return }
        if isHeartRateLoading && !force { return }
        await MainActor.run {
            isHeartRateLoading = true
        }
        await appState.refreshHealthData()
        await MainActor.run {
            isHeartRateLoading = false
        }
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

private struct HeartRateChartView: View {
    let samples: [HeartRateSample]

    var body: some View {
        Chart(samples) { sample in
            LineMark(
                x: .value("Time", sample.date),
                y: .value("BPM", sample.bpm)
            )
            .interpolationMethod(.monotone)
            PointMark(
                x: .value("Time", sample.date),
                y: .value("BPM", sample.bpm)
            )
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisTick()
                if let date = value.as(Date.self) {
                    AxisValueLabel(date.formatted(.dateTime.hour().minute()))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

private struct TodayOverview: View {
    let events: [Event]
    let assignments: [Assignment]
    let calendarLinked: Bool
    let onAddAssignment: () -> Void
    let onToggleAssignment: (Assignment, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendar Events")
                .font(.headline)
            if calendarLinked {
                if events.isEmpty {
                    Text("No events on your calendar today.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(events) { event in
                        EventCard(event: event)
                    }
                }
            } else {
                Text("Calendar Not Linked")
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Text("Assignments Due Today")
                    .font(.headline)
                Spacer()
                Button(action: onAddAssignment) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            if assignments.isEmpty {
                Text("No assignments due today.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(assignments) { assignment in
                    AssignmentRow(assignment: assignment) { completed in
                        onToggleAssignment(assignment, completed)
                    }
                }
            }
        }
        .padding()
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct AssignmentRow: View {
    let assignment: Assignment
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .fontWeight(.semibold)
                    .strikethrough(assignment.isCompleted, color: .secondary)
                Text("\(assignment.course) • \(assignment.dueDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !assignment.details.isEmpty {
                    Text(assignment.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                onToggle(!assignment.isCompleted)
            } label: {
                Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
