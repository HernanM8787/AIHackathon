import Foundation
import HealthKit

final class HealthKitService {
    private let store = HKHealthStore()

    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        let types: Set = [
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        try await store.requestAuthorization(toShare: [], read: types)
        return true
    }

    func latestRestingHeartRate() async throws -> Int? {
        let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let sample = samples?.first as? HKQuantitySample
                else {
                    continuation.resume(returning: nil)
                    return
                }

                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: Int(value.rounded()))
            }

            store.execute(query)
        }
    }
}
