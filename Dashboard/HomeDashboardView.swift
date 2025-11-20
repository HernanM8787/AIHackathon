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
        TabView(selection: $selectedTab) {
            matcher
                .tag(DashboardTab.matcher)
            dashboard
                .tag(DashboardTab.dashboard)
            assistant
                .tag(DashboardTab.assistant)
        }
        .toolbar(.hidden, for: .tabBar)
        .overlay(alignment: .bottom) {
            BottomTabBar(selected: $selectedTab)
                .padding(.bottom, 8)
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

    private var matcher: some View {
        NavigationStack {
            StudentMatcherView()
                .environmentObject(appState)
                .navigationTitle("Matcher")
        }
    }

    private var assistant: some View {
        NavigationStack {
            VirtualAssistantView()
                .environmentObject(appState)
                .navigationTitle("Assistant")
        }
    }

    private var dashboard: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Welcome, \(appState.userProfile.displayName)")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 8)
                    MetricCard(
                        title: "Reminders",
                        value: appState.permissionState.remindersGranted ? "Enabled" : "Not Linked"
                    )
                    MetricCard(
                        title: "Heart Rate",
                        value: heartRateDisplayText
                    )
                    Button {
                        Task {
                            await refreshHeartRateIfNeeded(force: true)
                        }
                    } label: {
                        Label(isHeartRateLoading ? "Refreshing..." : "Refresh Heart Rate", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                    }
                    .disabled(isHeartRateLoading || !appState.permissionState.healthKitGranted)
                    .padding(.bottom, 8)
                    if appState.permissionState.healthKitGranted {
                        if appState.heartRateHistory.isEmpty {
                            Text("No heart rate data from the last hour.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            HeartRateChartView(samples: appState.heartRateHistory)
                                .frame(height: 180)
                                .padding(.bottom, 4)
                        }
                    }

                    SectionHeader(title: "Today")
                    TodayOverview(
                        events: appState.deviceCalendarEvents,
                        assignments: assignmentsDueToday,
                        calendarLinked: appState.permissionState.calendarGranted,
                        onAddAssignment: { showingAddAssignment = true },
                        onToggleAssignment: { assignment, completed in
                            Task {
                                await appState.setAssignment(assignment, completed: completed)
                            }
                        }
                    )

                    SectionHeader(title: "Suggested Matches")
                    ForEach(appState.matches) { match in
                        MatchRow(match: match)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink("Calendar") { EventCalendarView() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AccountInformationView()) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
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
