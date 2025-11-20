import SwiftUI

struct EventCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false

    var body: some View {
        Group {
            if appState.permissionState.calendarGranted {
                List {
                    ForEach(appState.events) { event in
                        EventCard(event: event)
                    }
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Calendar access is not linked. Enable it from Permissions to sync events.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .navigationTitle("Events")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingCreateSheet = true }) {
                    Label("Create", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            NavigationStack { CreateEventView() }
        }
    }
}
