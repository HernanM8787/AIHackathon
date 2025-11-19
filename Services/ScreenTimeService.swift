import Foundation

final class ScreenTimeService {
    func requestAccess() async -> Bool {
        // TODO: Hook into Screen Time APIs (Shield extensions / DeviceActivity)
        return true
    }

    func currentUsageHours() async -> Double {
        // TODO: Read real metrics
        return 5.0
    }
}
