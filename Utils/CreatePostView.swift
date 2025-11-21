import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedCategory: PostCategory = .academics
    @State private var hashtags: [String] = []
    @State private var currentHashtag = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            Form {
                Section("Post Details") {
                    TextField("Title", text: $title)
                        .foregroundStyle(.white)
                    
                    TextField("Share your thoughts...", text: $bodyText, axis: .vertical)
                        .lineLimit(5...10)
                        .foregroundStyle(.white)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PostCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .foregroundStyle(.white)
                }
                .listRowBackground(Theme.card)
                
                Section("Hashtags (optional)") {
                    TextField("Add hashtag", text: $currentHashtag)
                        .foregroundStyle(.white)
                        .onSubmit {
                            addHashtag()
                        }
                    
                    if !hashtags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(hashtags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text("#\(tag)")
                                            .font(.caption)
                                        Button(action: { removeHashtag(tag) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.purple.opacity(0.3))
                                    )
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Theme.card)
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    .listRowBackground(Theme.card)
                }
                
                Section {
                    Button(action: savePost) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isSaving ? "Posting..." : "Post")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .disabled(title.isEmpty || bodyText.isEmpty || isSaving)
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
        }
        .navigationTitle("New Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
                    .foregroundStyle(.white)
                    .disabled(isSaving)
            }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func addHashtag() {
        let trimmed = currentHashtag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !hashtags.contains(trimmed) else { return }
        hashtags.append(trimmed)
        currentHashtag = ""
    }
    
    private func removeHashtag(_ tag: String) {
        hashtags.removeAll { $0 == tag }
    }
    
    private func savePost() {
        guard !title.isEmpty, !bodyText.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let newPost = Post(
                    id: "",
                    userId: appState.peerSupportAnonId,
                    title: title,
                    body: bodyText,
                    category: selectedCategory,
                    hashtags: hashtags,
                    careCount: 0,
                    commentCount: 0,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                let firebaseService = FirebaseService()
                try await firebaseService.createPost(post: newPost)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to create post: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}

