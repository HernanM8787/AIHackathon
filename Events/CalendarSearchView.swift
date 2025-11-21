import SwiftUI

struct CalendarSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var searchType: SearchType = .all
    
    enum SearchType: String, CaseIterable {
        case all = "All"
        case events = "Events"
        case assignments = "Assignments"
    }
    
    private var filteredEvents: [Event] {
        let events = appState.deviceCalendarEvents
        guard !searchText.isEmpty else { return events }
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(searchText) ||
            event.location.localizedCaseInsensitiveContains(searchText) ||
            event.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredAssignments: [Assignment] {
        let assignments = appState.assignments
        guard !searchText.isEmpty else { return assignments }
        return assignments.filter { assignment in
            assignment.title.localizedCaseInsensitiveContains(searchText) ||
            assignment.course.localizedCaseInsensitiveContains(searchText) ||
            assignment.details.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    
                    TextField("Search events and assignments...", text: $searchText)
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.15))
                )
                .padding()
                
                // Filter buttons
                HStack(spacing: 12) {
                    ForEach(SearchType.allCases, id: \.self) { type in
                        Button(action: { searchType = type }) {
                            Text(type.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(searchType == type ? .black : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(searchType == type ? Color.white : Color(white: 0.15))
                                )
                        }
                    }
                }
                .padding(.horizontal)
                
                // Results
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if searchType == .all || searchType == .events {
                            if filteredEvents.isEmpty {
                                if !searchText.isEmpty {
                                    Text("No events found")
                                        .foregroundStyle(.gray)
                                        .padding()
                                }
                            } else {
                                Text("Events")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                
                                ForEach(filteredEvents) { event in
                                    EventCard(event: event)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        if searchType == .all || searchType == .assignments {
                            if filteredAssignments.isEmpty {
                                if !searchText.isEmpty {
                                    Text("No assignments found")
                                        .foregroundStyle(.gray)
                                        .padding()
                                }
                            } else {
                                Text("Assignments")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                
                                ForEach(filteredAssignments) { assignment in
                                    AssignmentRowCard(assignment: assignment)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        if searchText.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                                Text("Search for events and assignments")
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

