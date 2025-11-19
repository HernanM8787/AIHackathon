import SwiftUI

struct PreferenceSetupView: View {
    @State private var gymPreference = ""
    @State private var studyPreference = ""
    @State private var newClass = ""
    @State private var classes: [String] = []

    var onFinish: () -> Void

    var body: some View {
        Form {
            Section("Gym buddy") {
                TextField("e.g. Morning cardio", text: $gymPreference)
            }
            Section("Study partner") {
                TextField("e.g. Evening focus", text: $studyPreference)
            }
            Section("Classes") {
                HStack {
                    TextField("Add class", text: $newClass)
                    Button("Add") { appendClass() }
                        .disabled(newClass.isEmpty)
                }
                ForEach(classes, id: \.self) { course in
                    Text(course)
                }
                .onDelete(perform: deleteClass)
            }
            Button("Finish") { onFinish() }
                .disabled(gymPreference.isEmpty || studyPreference.isEmpty)
        }
    }

    private func appendClass() {
        classes.append(newClass)
        newClass = ""
    }

    private func deleteClass(at offsets: IndexSet) {
        classes.remove(atOffsets: offsets)
    }
}
