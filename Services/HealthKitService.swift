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

    func latestHeartRate() async throws -> Int? {
        try await latestHeartRateSample(for: .heartRate)
    }

    func latestRestingHeartRate() async throws -> Int? {
        try await latestHeartRateSample(for: .restingHeartRate)
    }

    func heartRateSamples(since startDate: Date, limit: Int = 200) async throws -> [HeartRateSample] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let mapped: [HeartRateSample] = (samples as? [HKQuantitySample])?.map {
                    let value = $0.quantity.doubleValue(for: unit)
                    return HeartRateSample(date: $0.startDate, bpm: Int(value.rounded()))
                } ?? []
                continuation.resume(returning: mapped)
            }

            store.execute(query)
        }
    }

    private func latestHeartRateSample(for identifier: HKQuantityTypeIdentifier) async throws -> Int? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
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
