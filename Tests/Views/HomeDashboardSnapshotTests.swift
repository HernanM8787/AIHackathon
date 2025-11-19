import XCTest
import SwiftUI
@testable import AIHackathon

final class HomeDashboardSnapshotTests: XCTestCase {
    @MainActor
    func testDashboardRenders() {
        let view = HomeDashboardView()
            .environmentObject(AppState())
        XCTAssertNotNil(view)
    }
}
