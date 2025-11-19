import SwiftUI

struct EventCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false

    var body: some View {
        List {
            ForEach(appState.events) { event in
                EventCard(event: event)
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
