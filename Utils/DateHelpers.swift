import Foundation

final class DateHelpers {
    static let shared = DateHelpers()
    private let formatter: DateFormatter

    private init() {
        formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
    }

    func rangeString(start: Date, end: Date) -> String {
        "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
