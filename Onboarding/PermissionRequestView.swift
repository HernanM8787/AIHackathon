import SwiftUI

struct PermissionRequestView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isProcessing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Permissions")
                .font(.title2.bold())
            Text("Grant access once now or skip and manage later from Account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            PermissionCard(title: "Reminders", granted: appState.permissionState.remindersGranted) {
                await requestReminders()
            }
            PermissionCard(title: "HealthKit", granted: appState.permissionState.healthKitGranted) {
                await requestHealthKit()
            }
            PermissionCard(title: "Calendar", granted: appState.permissionState.calendarGranted) {
                await requestCalendar()
            }
            Spacer()
            if isProcessing { ProgressView() }
            Button("Skip for now") {
                withAnimation {
                    appState.markOnboardingComplete()
                }
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func requestReminders() async {
        isProcessing = true
        let granted = await CalendarService().requestReminderAccess()
        _ = await appState.requestRemindersPermission()
        isProcessing = false
    }

    private func requestHealthKit() async {
        isProcessing = true
        _ = await appState.requestHealthKitPermission()
        isProcessing = false
    }

    private func requestCalendar() async {
        isProcessing = true
        _ = await appState.requestCalendarPermission()
        isProcessing = false
    }
}

private struct PermissionCard: View {
    let title: String
    let granted: Bool
    let action: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: granted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(granted ? Color.green : Color.gray)
            }
            Button(granted ? "Granted" : "Grant Access", action: perform)
                .buttonStyle(.borderedProminent)
                .disabled(granted)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func perform() {
        Task { await action() }
    }
}
