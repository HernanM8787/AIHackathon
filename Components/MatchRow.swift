import SwiftUI

struct MatchRow: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(match.peerName).font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", match.compatibilityScore * 100))
                    .font(.subheadline)
            }
            Text(match.overlapSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
