import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: DashboardTab = .dashboard

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
                case .profile:
                    profileView
                }
            }
            
            VStack {
                Spacer()
                BottomTabBar(selected: $selectedTab)
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
    
    private var profileView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Profile View")
                .foregroundStyle(.white)
        }
    }

    private var dashboard: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with profile and welcome
                    HStack(spacing: 12) {
                        // Profile picture
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Text(appState.userProfile.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
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
                            if appState.events.isEmpty {
                                Text("No upcoming events in your calendar.")
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(Array(appState.events.prefix(5))) { event in
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
                    .padding(.bottom, 100) // Space for bottom tab bar
                }
            }
        }
        .navigationBarHidden(true)
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
