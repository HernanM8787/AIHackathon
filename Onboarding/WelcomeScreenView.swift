import SwiftUI

struct WelcomeScreenView: View {
    @EnvironmentObject private var appState: AppState
    @State private var glowIntensity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Abstract blob shape at the top
                GeometryReader { geometry in
                    ZStack {
                        // Pulsing glow layers
                        blobPath(geometry: geometry)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.4, blue: 0.5).opacity(glowIntensity * 0.6),
                                        Color(red: 0.2, green: 0.2, blue: 0.3).opacity(glowIntensity * 0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .blur(radius: 30)
                            .opacity(glowIntensity)
                        
                        blobPath(geometry: geometry)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.3, blue: 0.4).opacity(glowIntensity * 0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 60
                                )
                            )
                            .blur(radius: 20)
                            .opacity(glowIntensity * 0.8)
                        
                        // Main blob shape
                        blobPath(geometry: geometry)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.2, blue: 0.25),
                                        Color(red: 0.15, green: 0.15, blue: 0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: Color(red: 0.4, green: 0.4, blue: 0.6).opacity(glowIntensity * 0.5),
                                radius: 20 * glowIntensity,
                                x: 0,
                                y: 0
                            )
                            .overlay(
                                blobPath(geometry: geometry)
                                    .stroke(Color(red: 0.1, green: 0.1, blue: 0.15), lineWidth: 2)
                            )
                    }
                }
                .frame(height: 200)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        glowIntensity = 1.0
                    }
                }
                
                Spacer()
                
                VStack(spacing: 24) {
                    // AI Daily Focus Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                            Text("AI DAILY FOCUS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                        }
                        
                        Text("\"Embrace the quiet moments between deadlines. Your mind, like a seed, needs rest to grow.\"")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                    )
                    .padding(.horizontal)
                    
                    // Welcome Message
                    VStack(spacing: 12) {
                        Text("Welcome to Balance")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Your AI partner in navigating academic life with a calm mind.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Begin Your Journey Button
                    Button(action: {
                        appState.showSignup()
                    }) {
                        Text("Begin Your Journey")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.8), // Medium purple
                                        Color(red: 99/255.0, green: 102/255.0, blue: 241/255.0) // Matching account page color
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // I Already Have an Account Link
                    Button(action: {
                        appState.showLogin()
                    }) {
                        Text("I Already Have an Account")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func blobPath(geometry: GeometryProxy) -> Path {
        Path { path in
            let width = geometry.size.width * 1.0  // Stretch more horizontally
            let height = geometry.size.height * 0.7  // Stretch more vertically
            let centerX = geometry.size.width * 0.5  // Center horizontally
            let centerY = geometry.size.height * 0.4  // Center vertically
            
            // Create an organic blob shape
            path.move(to: CGPoint(x: centerX - width * 0.3, y: centerY - height * 0.2))
            path.addCurve(
                to: CGPoint(x: centerX + width * 0.4, y: centerY - height * 0.1),
                control1: CGPoint(x: centerX - width * 0.1, y: centerY - height * 0.3),
                control2: CGPoint(x: centerX + width * 0.2, y: centerY - height * 0.2)
            )
            path.addCurve(
                to: CGPoint(x: centerX + width * 0.3, y: centerY + height * 0.4),
                control1: CGPoint(x: centerX + width * 0.5, y: centerY + height * 0.1),
                control2: CGPoint(x: centerX + width * 0.4, y: centerY + height * 0.3)
            )
            path.addCurve(
                to: CGPoint(x: centerX - width * 0.2, y: centerY + height * 0.3),
                control1: CGPoint(x: centerX + width * 0.1, y: centerY + height * 0.5),
                control2: CGPoint(x: centerX - width * 0.1, y: centerY + height * 0.4)
            )
            path.addCurve(
                to: CGPoint(x: centerX - width * 0.3, y: centerY - height * 0.2),
                control1: CGPoint(x: centerX - width * 0.4, y: centerY + height * 0.1),
                control2: CGPoint(x: centerX - width * 0.3, y: centerY - height * 0.1)
            )
            path.closeSubpath()
        }
    }
}

#Preview {
    WelcomeScreenView()
        .environmentObject(AppState())
}

