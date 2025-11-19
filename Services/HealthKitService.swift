import Foundation
import HealthKit

final class HealthKitService {
    private let store = HKHealthStore()

    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        let types: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        try await store.requestAuthorization(toShare: [], read: types)
        return true
    }
}
