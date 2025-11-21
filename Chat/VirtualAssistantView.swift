import SwiftUI

struct VirtualAssistantView: View {
    @EnvironmentObject private var appState: AppState
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Hi there! I can offer quick wellness and productivity ideas based on your dashboard. What would you like help with?")
    ]
    @State private var input: String = ""
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool
    private let service = GeminiService()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: messages.count) { _, _ in
                        guard let id = messages.last?.id else { return }
                        DispatchQueue.main.async {
                            withAnimation(.easeOut) {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Chat input bar
                VStack(spacing: 0) {
                    Divider()
                        .background(Color(white: 0.2))
                    inputBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(white: 0.1))
                }
            }
        }
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask about focus, energy, classes...", text: $input, axis: .vertical)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .disabled(isSending)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(white: 0.15))
                )
                .foregroundStyle(.white)
                .lineLimit(1...5)

            if isSending {
                ProgressView()
                    .tint(.white)
                    .frame(width: 44, height: 44)
            } else {
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white)
                        )
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
        }
    }

    private func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        let userMessage = ChatMessage(role: .user, text: trimmed)
        messages.append(userMessage)
        input = ""
        isSending = true
        isInputFocused = false

        let history = messages
        Task {
            do {
                let reply = try await service.sendChat(messages: history, profile: appState.userProfile)
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, text: reply))
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, text: "I ran into an issue: \(error.localizedDescription)"))
                    isSending = false
                }
            }
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer()
            } else {
                Spacer()
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(message.role == .assistant ? .white : .black)
            .background(
                message.role == .assistant
                ? Color(white: 0.2)
                : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .assistant ? .leading : .trailing)
    }
}
