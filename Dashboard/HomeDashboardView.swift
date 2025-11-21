import SwiftUI
import Combine
import Charts

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: DashboardTab = .home
    @State private var isHeartRateLoading = false
    private let heartRateRefreshInterval: TimeInterval = 300
    @State private var heartRateTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    @State private var showingCreatePost = false
    @State private var showingProfile = false

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .home:
                    dashboard
                case .assistant:
                    assistantView
                case .add:
                    addView
                case .calendar:
                    calendarView
                case .forum:
                    peerSupportView
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
        .task(id: appState.userProfile.id) {
            await appState.refreshStressLevels()
        }
        .onChange(of: appState.events) {
            Task { await appState.refreshStressLevels() }
        }
        .onChange(of: appState.assignments) {
            Task { await appState.refreshStressLevels() }
        }
        .sheet(isPresented: $showingCreatePost) {
            NavigationStack {
                CreatePostView()
                    .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingProfile) {
            NavigationStack {
                ProfileView()
                    .environmentObject(appState)
            }
        }
        .onReceive(heartRateTimer) { _ in
            Task {
                await refreshHeartRateIfNeeded()
            }
        }
    }

    private var assistantView: some View {
        NavigationStack {
            VirtualAssistantView()
                .environmentObject(appState)
                .navigationTitle("Assistant")
        }
    }
    
    private var addView: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                    Text("Create a new anonymous post for the Forum.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                    Button {
                        showingCreatePost = true
                    } label: {
                        Text("Start a Post")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.white))
                    }
                }
                .padding()
            }
            .navigationTitle("Create")
        }
    }
    
    private var calendarView: some View {
        NavigationStack {
            EventCalendarView()
                .environmentObject(appState)
        }
    }
    
    private var peerSupportView: some View {
        NavigationStack {
            PeerSupportView()
                .environmentObject(appState)
                .navigationTitle("Forum")
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
                        Button(action: { showingProfile = true }) {
                            SchoolLogoView(school: appState.userProfile.school, size: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
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
                        
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    StressLevelGraphView(samples: appState.stressSamples)
                        .padding(.horizontal)
                    
                    // AI Insight Card
                    AIInsightCard(
                        insight: "Your mood is stable, but your upcoming PSY-201 exam might be a stressor. Prioritizing study breaks could improve focus and wellbeing."
                    )
                    .padding(.horizontal)
                    
                    // Activity Cards (side by side)
                    HStack(spacing: 12) {
                        ActivityCard(
                            title: "Heart Rate",
                            value: heartRateDisplayText,
                            icon: "heart.fill",
                            progress: nil
                        )
                        
                        ActivityCard(
                            title: "Upcoming Assignments",
                            value: assignmentCompletionLabel,
                            icon: "checklist",
                            progress: weeklyAssignmentProgress
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
    
    private var weeklyAssignments: [Assignment] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? today
        return appState.assignments.filter { $0.dueDate >= start && $0.dueDate < end }
    }
    
    private var assignmentsCompletedThisWeek: Int {
        weeklyAssignments.filter { $0.isCompleted }.count
    }
    
    private var assignmentCompletionLabel: String {
        let total = weeklyAssignments.count
        if total == 0 {
            return "0/0 completed"
        }
        return "\(assignmentsCompletedThisWeek)/\(total) completed"
    }
    
    private var weeklyAssignmentProgress: Double? {
        let total = weeklyAssignments.count
        guard total > 0 else { return 0 }
        return Double(assignmentsCompletedThisWeek) / Double(total)
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

private struct StressLevelGraphView: View {
    let samples: [StressSample]
    private let currentHour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Stress Level")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("0 – 10")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            if samples.isEmpty {
                Text("No stress data yet. Keep logging events and heart rate.")
                    .font(.caption)
                    .foregroundStyle(.gray)
            } else {
                Chart {
                    ForEach(samples) { sample in
                        AreaMark(
                            x: .value("Hour", sample.hour),
                            y: .value("Stress", sample.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.35),
                                    Color.purple.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    ForEach(samples) { sample in
                        LineMark(
                            x: .value("Hour", sample.hour),
                            y: .value("Stress", sample.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.purple)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                    if let current = samples.first(where: { $0.hour == currentHour }) {
                        RuleMark(x: .value("Hour", currentHour))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(Color.white.opacity(0.4))
                        PointMark(
                            x: .value("Hour", current.hour),
                            y: .value("Stress", current.value)
                        )
                        .foregroundStyle(Color.white)
                    }
                }
                .chartYScale(domain: 0...10)
                .chartXAxis {
                    AxisMarks(values: Array(stride(from: 0, through: 23, by: 3))) { value in
                        AxisGridLine()
                        AxisTick()
                        if let hour = value.as(Int.self) {
                            AxisValueLabel("\(hour)")
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: Array(stride(from: 0, through: 10, by: 2)))
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.12))
        )
    }
}
