import SwiftUI

struct CalendarSuggestionCard: View {
    let title: String
    let message: String
    var onStart: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.accent)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            Text(message)
                .foregroundStyle(Theme.subtitle)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 16) {
                Button(action: { onStart?() }) {
                    Text("Start Activity")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Theme.accentGradient)
                        )
                }
                
                Button(action: { onDismiss?() }) {
                    Text("Dismiss")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.subtitle)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.outline, lineWidth: 1)
                )
        )
    }
}

