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
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
                .background(Color(.systemGroupedBackground))
                .onChange(of: messages.count) { _, _ in
                    guard let id = messages.last?.id else { return }
                    DispatchQueue.main.async {
                        withAnimation(.easeOut) {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            Divider()
            inputBar
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Material.bar)
        }
        .navigationTitle("AI Assistant")
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ask about focus, energy, classes...", text: $input, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .disabled(isSending)

            if isSending {
                ProgressView()
                    .padding(.horizontal, 8)
            } else {
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.accentColor, in: Circle())
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .padding(12)
            .foregroundStyle(message.role == .assistant ? Color.primary : Color.white)
            .background(
                message.role == .assistant
                ? Color(.secondarySystemBackground)
                : Color.accentColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
