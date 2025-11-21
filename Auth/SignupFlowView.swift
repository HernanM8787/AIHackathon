import SwiftUI

struct SignupFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showStep2 = false
    
    var body: some View {
        NavigationStack {
            SignupStep1View(
                email: $email,
                password: $password,
                onNext: {
                    showStep2 = true
                }
            )
            .navigationDestination(isPresented: $showStep2) {
                SignupStep2View(
                    email: email,
                    password: password
                )
            }
        }
    }
}

