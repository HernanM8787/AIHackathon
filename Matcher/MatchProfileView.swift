import SwiftUI
import UIKit

struct MatchProfileView: View {
    let match: Match

    var body: some View {
        Form {
            Section("Shared classes") {
                ForEach(match.sharedClasses, id: \.self, content: Text.init)
            }
            Section("Compatibility") {
                LabeledContent("Score", value: String(format: "%.0f%%", match.compatibilityScore * 100))
                Text(match.overlapSummary)
            }
            Section("Connect") {
                Button("Send message") { }
                Button("Copy contact: \(match.contactMethod)") {
                    UIPasteboard.general.string = match.contactMethod
                }
            }
        }
        .navigationTitle(match.peerName)
    }
}
