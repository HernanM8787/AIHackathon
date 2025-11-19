import SwiftUI

struct StudentMatcherView: View {
    @EnvironmentObject private var appState: AppState
    @State private var classFilter = ""
    @State private var gymFilter = false
    @State private var studyFilter = false

    var body: some View {
        List {
            filterSection
            ForEach(filteredMatches) { match in
                NavigationLink(destination: MatchProfileView(match: match)) {
                    MatchRow(match: match)
                }
            }
        }
        .navigationTitle("Matcher")
    }

    private var filteredMatches: [Match] {
        appState.matches.filter { match in
            let classMatch = classFilter.isEmpty || match.sharedClasses.contains(where: { $0.localizedCaseInsensitiveContains(classFilter) })
            let gym = !gymFilter || match.overlapSummary.contains("gym")
            let study = !studyFilter || match.overlapSummary.contains("study")
            return classMatch && gym && study
        }
    }

    @ViewBuilder
    private var filterSection: some View {
        Section("Filters") {
            TextField("Class", text: $classFilter)
            Toggle("Gym buddy", isOn: $gymFilter)
            Toggle("Study partner", isOn: $studyFilter)
        }
    }
}
