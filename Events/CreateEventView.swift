import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var description = ""

    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Location", text: $location)
            DatePicker("Start", selection: $startDate)
            DatePicker("End", selection: $endDate)
            TextField("Description", text: $description, axis: .vertical)
            Button("Save", action: save)
                .disabled(title.isEmpty)
        }
        .navigationTitle("Create Event")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", action: dismiss.callAsFunction)
            }
        }
    }

    private func save() {
        // TODO: Persist via FirebaseService
        dismiss()
    }
}
