import SwiftUI

struct ActivityCard: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.accent)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.accent.opacity(0.1))
                    )
                Spacer()
            }
            
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.subtitle)
                .tracking(0.8)
            
            if let progress {
                VStack(alignment: .leading, spacing: 10) {
                    SmallStatLabel(text: value)
                    ProgressBar(progress: progress)
                }
            } else {
                Text(value)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Theme.outline, lineWidth: 1)
                )
        )
    }
}

private struct SmallStatLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(.title2, design: .rounded).weight(.bold))
            .foregroundStyle(.white)
    }
}

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Theme.outline)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Theme.accentGradient)
                    .frame(width: geometry.size.width * max(0, min(1, progress)), height: 4)
            }
        }
        .frame(height: 4)
    }
}

