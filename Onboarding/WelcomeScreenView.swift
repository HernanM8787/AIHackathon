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
                
                // Glowing circle blob
                GeometryReader { geometry in
                    ZStack {
                        let centerX = geometry.size.width * 0.5
                        let centerY = geometry.size.height * 0.5
                        let radius: CGFloat = min(geometry.size.width, geometry.size.height) * 0.25
                        
                        // Outer glow layer
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.6, green: 0.5, blue: 0.8).opacity(glowIntensity * 0.9),
                                        Color(red: 0.4, green: 0.4, blue: 0.6).opacity(glowIntensity * 0.7),
                                        Color(red: 0.3, green: 0.3, blue: 0.5).opacity(glowIntensity * 0.5),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: radius * 0.5,
                                    endRadius: radius * 2.5
                                )
                            )
                            .frame(width: radius * 5, height: radius * 5)
                            .blur(radius: 40)
                            .opacity(glowIntensity)
                            .position(x: centerX, y: centerY)
                        
                        // Middle glow layer
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.5, green: 0.4, blue: 0.7).opacity(glowIntensity * 0.8),
                                        Color(red: 0.3, green: 0.3, blue: 0.5).opacity(glowIntensity * 0.6),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: radius * 0.3,
                                    endRadius: radius * 1.8
                                )
                            )
                            .frame(width: radius * 3.6, height: radius * 3.6)
                            .blur(radius: 30)
                            .opacity(glowIntensity * 1.0)
                            .position(x: centerX, y: centerY)
                        
                        // Main glowing circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.2, blue: 0.25),
                                        Color(red: 0.15, green: 0.15, blue: 0.2)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: radius
                                )
                            )
                            .frame(width: radius * 2, height: radius * 2)
                            .shadow(
                                color: Color(red: 0.6, green: 0.5, blue: 0.8).opacity(glowIntensity * 0.8),
                                radius: 30 * glowIntensity,
                                x: 0,
                                y: 0
                            )
                            .position(x: centerX, y: centerY)
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
    
}

#Preview {
    WelcomeScreenView()
        .environmentObject(AppState())
}

