import SwiftUI
import PhotosUI

struct VirtualAssistantView: View {
    @EnvironmentObject private var appState: AppState
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Hi there! I can offer quick wellness and productivity ideas based on your dashboard. What would you like help with?")
    ]
    @State private var input: String = ""
    @State private var isSending = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
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
        VStack(spacing: 8) {
            if let selectedImage = selectedImage {
                HStack {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { selectedImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            
            HStack(spacing: 8) {
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                        .padding(10)
                }
                .disabled(isSending)
                
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
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
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
