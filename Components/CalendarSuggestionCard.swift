import SwiftUI

struct CalendarSuggestionCard: View {
    let title: String
    let message: String
    var onStart: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.white)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            Text(message)
                .foregroundStyle(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 16) {
                Button(action: { onStart?() }) {
                    Text("Start Activity")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                
                Button(action: { onDismiss?() }) {
                    Text("Dismiss")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.12))
        )
    }
}

