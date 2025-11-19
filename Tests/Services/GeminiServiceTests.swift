import XCTest
@testable import AIHackathon

final class GeminiServiceTests: XCTestCase {
    func testMockResponseContainsTips() async throws {
        let service = GeminiService()
        let response = try await service.generateTips(for: .mock)
        XCTAssertFalse(response.tips.isEmpty)
    }
}
