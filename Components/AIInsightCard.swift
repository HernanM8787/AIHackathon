import SwiftUI

struct AIInsightCard: View {
    let insight: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            
            Text(insight)
                .font(.subheadline)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
}

