import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: DashboardTab = .dashboard

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
                        title: "Screen Time",
                        value: String(format: "%.1f h", appState.userProfile.metrics.screenTimeHours)
                    )
                    MetricCard(
                        title: "Heart Rate",
                        value: "\(appState.userProfile.metrics.restingHeartRate) bpm"
                    )
                    SectionHeader(title: "Suggested Matches")
                    ForEach(appState.matches) { match in
                        MatchRow(match: match)
                    }
                    SectionHeader(title: "Upcoming Events")
                    ForEach(appState.events) { event in
                        EventCard(event: event)
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
                    Button("Sign Out", role: .destructive) {
                        Task {
                            await appState.signOut()
                        }
                    }
                }
            }
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
