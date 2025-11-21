import SwiftUI
import FirebaseFirestore

struct PostDetailView: View {
    let post: Post
    let myAnonymousId: String
    
    @EnvironmentObject private var appState: AppState
    @State private var comments: [Comment] = []
    @State private var newComment = ""
    @State private var isSending = false
    @State private var commentsListener: ListenerRegistration?
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Post Metadata
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.title)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 8) {
                                Text(post.category.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Theme.accent.opacity(0.2)))
                                    .foregroundStyle(Theme.accent)
                                
                                Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(Theme.subtitle)
                            }
                        }
                        
                        // Body
                        Text(post.body)
                            .font(.body)
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !post.hashtags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                                ForEach(post.hashtags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Theme.surface))
                                }
                            }
                        }
                        
                        Divider()
                            .background(Theme.outline)
                        
                        // Comments Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comments")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            if comments.isEmpty {
                                Text("No comments yet. Start the conversation!")
                                    .font(.caption)
                                    .foregroundStyle(Theme.subtitle)
                            } else {
                                ForEach(comments) { comment in
                                    CommentRow(comment: comment)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Comment Composer
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Share support or encouragement...", text: $newComment, axis: .vertical)
                        .lineLimit(2...4)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Theme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Theme.outline, lineWidth: 1)
                                )
                        )
                    
                    Button(action: sendComment) {
                        HStack {
                            if isSending {
                                ProgressView()
                            }
                            Text(isSending ? "Sending..." : "Send")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Theme.accentGradient)
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }
                .padding()
            }
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startCommentsListener() }
        .onDisappear {
            commentsListener?.remove()
            commentsListener = nil
        }
    }
    
    private func startCommentsListener() {
        commentsListener?.remove()
        commentsListener = FirebaseService().observeComments(for: post.id) { newComments in
            DispatchQueue.main.async {
                self.comments = newComments
            }
        }
    }
    
    private func sendComment() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSending = true
        let comment = Comment(
            id: UUID().uuidString,
            postId: post.id,
            userId: myAnonymousId,
            body: trimmed,
            careCount: 0,
            createdAt: Date(),
            userIconType: .random
        )
        
        Task {
            do {
                try await FirebaseService().addComment(postId: post.id, comment: comment)
                await MainActor.run {
                    newComment = ""
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    isSending = false
                }
            }
        }
    }
}

private struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Theme.surface)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: comment.userIconType.systemImage)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Anonymous")
                    .font(.caption)
                    .foregroundStyle(Theme.subtitle)
                Text(comment.body)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.outline, lineWidth: 1)
                )
        )
    }
}


