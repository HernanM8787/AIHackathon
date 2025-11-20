import SwiftUI

struct AddAssignmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var title = ""
    @State private var course = ""
    @State private var dueDate = Date()
    @State private var details = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var createReminder = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Assignment") {
                    TextField("Title", text: $title)
                    TextField("Course", text: $course)
                    DatePicker("Due Date", selection: $dueDate)
                    TextField("Notes", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                    Toggle("Add to Reminders", isOn: $createReminder)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button(action: save) {
                        HStack {
                            if isSaving {
                                ProgressView()
                            }
                            Text(isSaving ? "Saving..." : "Save Assignment")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .navigationTitle("New Assignment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .disabled(isSaving)
                }
            }
        }
    }

    private func save() {
        guard !title.isEmpty else { return }
        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await appState.addAssignment(
                    title: title,
                    course: course,
                    dueDate: dueDate,
                    details: details,
                    createReminder: createReminder
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
}

