import SwiftUI

struct MentalStateCard: View {
    @State private var selectedPeriod = "This week"
    
    private let mentalStateData: [(day: String, value: Double)] = [
        ("M", 3.5),
        ("T", 4.2),
        ("W", 5.8),
        ("T", 6.2),
        ("F", 5.5),
        ("S", 4.0),
        ("S", 3.8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with tag and dropdown
            HStack {
                HStack(spacing: 6) {
                    Text("Good")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 6, height: 6)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(white: 0.2))
                )
                
                Spacer()
                
                Menu {
                    Button("This week") { selectedPeriod = "This week" }
                    Button("This month") { selectedPeriod = "This month" }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedPeriod)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Text("Mental State")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            // Line graph
            VStack(spacing: 0) {
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color(white: 0.1))
                                .frame(height: 1)
                            Spacer()
                        }
                    }
                    .frame(height: 100)
                    
                    // Graph
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let maxValue = mentalStateData.map { $0.value }.max() ?? 7
                        let minValue = mentalStateData.map { $0.value }.min() ?? 0
                        let range = maxValue - minValue
                        let stepX = width / CGFloat(mentalStateData.count - 1)
                        
                        ZStack {
                            // Area fill
                            Path { path in
                                for (index, data) in mentalStateData.enumerated() {
                                    let x = CGFloat(index) * stepX
                                    let normalizedValue = (data.value - minValue) / range
                                    let y = height - (normalizedValue * height)
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: height))
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                                
                                // Close the path
                                if let last = mentalStateData.last {
                                    let lastX = CGFloat(mentalStateData.count - 1) * stepX
                                    path.addLine(to: CGPoint(x: lastX, y: height))
                                    path.closeSubpath()
                                }
                            }
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Line
                            Path { path in
                                for (index, data) in mentalStateData.enumerated() {
                                    let x = CGFloat(index) * stepX
                                    let normalizedValue = (data.value - minValue) / range
                                    let y = height - (normalizedValue * height)
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(.blue, lineWidth: 2)
                            
                            // Data points
                            ForEach(Array(mentalStateData.enumerated()), id: \.offset) { index, data in
                                let x = CGFloat(index) * stepX
                                let normalizedValue = (data.value - minValue) / range
                                let y = height - (normalizedValue * height)
                                
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 6, height: 6)
                                    .position(x: x, y: y)
                            }
                        }
                    }
                    .frame(height: 100)
                }
                
                // X-axis labels
                HStack(spacing: 0) {
                    ForEach(mentalStateData, id: \.day) { data in
                        Text(data.day)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        if data.day != mentalStateData.last?.day {
                            Spacer()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .frame(height: 120)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
}

