import SwiftUI

struct ActivityCard: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            if let progress = progress {
                VStack(alignment: .leading, spacing: 6) {
                    SmallStatLabel(text: value)
                    ProgressBar(progress: progress)
                }
            } else {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
}

private struct SmallStatLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
    }
}

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(white: 0.2))
                            .frame(height: 2)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue)
                            .frame(width: geometry.size.width * max(0, min(1, progress)), height: 2)
                    }
                }
                .frame(height: 2)
        }
    }
}

