import SwiftUI
import PhotosUI

struct VirtualAssistantView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: DashboardTab
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "I'm your AI assistant")
    ]
    @State private var input: String = ""
    @State private var isSending = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @FocusState private var isInputFocused: Bool
    private let service = GeminiService()
    
    init(selectedTab: Binding<DashboardTab>) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header with back button
                HStack {
                    Button(action: {
                        selectedTab = .home
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Home")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Text("AI Assistant")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Spacer to balance the back button
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Home")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .opacity(0)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.black)
                
                // Messages area - takes available space
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
                        .padding(.bottom, 20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: messages.count) { _, _ in
                        guard let id = messages.last?.id else { return }
                        DispatchQueue.main.async {
                            withAnimation(.easeOut) {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isInputFocused) { _, isFocused in
                        if isFocused {
                            // Scroll to bottom when keyboard appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                guard let id = messages.last?.id else { return }
                                withAnimation(.easeOut) {
                                    proxy.scrollTo(id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input bar - positioned above nav bar, will be pushed up by keyboard
                VStack(spacing: 0) {
                    Divider()
                        .background(Color(white: 0.2))
                    inputBar
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(white: 0.1))
                }
                .padding(.bottom, 80) // Space for nav bar at bottom
            }
        }
        .navigationBarHidden(true)
    }

    private var inputBar: some View {
        VStack(spacing: 8) {
            if let previewImage = selectedImage {
                HStack {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { self.selectedImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            
            HStack(spacing: 12) {
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "photo")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                }
                .disabled(isSending)
                
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
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
                    .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil ? 0.5 : 1.0)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmed.isEmpty
        let hasImage = selectedImage != nil
        
        guard hasText || hasImage else { return }
        
        // Convert UIImage to Data
        var imageData: Data? = nil
        if let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        let userMessage = ChatMessage(
            role: .user,
            text: trimmed.isEmpty ? "What do you see in this image?" : trimmed,
            imageData: imageData
        )
        messages.append(userMessage)
        input = ""
        selectedImage = nil
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
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = message.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 250, maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if !message.text.isEmpty {
                Text(message.text)
            }
        }
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
