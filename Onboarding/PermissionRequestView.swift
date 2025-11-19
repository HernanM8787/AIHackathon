import SwiftUI

struct PermissionRequestView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isProcessing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Permissions")
                .font(.title2.bold())
            PermissionCard(title: "Screen Time", granted: appState.permissionState.screenTimeGranted) {
                await requestScreenTime()
            }
            PermissionCard(title: "HealthKit", granted: appState.permissionState.healthKitGranted) {
                await requestHealthKit()
            }
            PermissionCard(title: "Calendar", granted: appState.permissionState.calendarGranted) {
                await requestCalendar()
            }
            Spacer()
            if isProcessing { ProgressView() }
        }
        .padding()
    }

    private func requestScreenTime() async {
        isProcessing = true
        appState.permissionState.screenTimeGranted = await ScreenTimeService().requestAccess()
        isProcessing = false
    }

    private func requestHealthKit() async {
        isProcessing = true
        appState.permissionState.healthKitGranted = (try? await HealthKitService().requestAuthorization()) ?? false
        isProcessing = false
    }

    private func requestCalendar() async {
        isProcessing = true
        appState.permissionState.calendarGranted = await CalendarService().requestAccess()
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
