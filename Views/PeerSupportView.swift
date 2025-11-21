import SwiftUI

struct PeerSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var selectedCategory: PostCategory = .all
    @State private var showingCreatePost = false
    @State private var posts: [Post] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Text("Peer Support")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Community Guidelines Card
                        CommunityGuidelinesCard()
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Category Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(PostCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                        loadPosts()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Posts Feed
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            let filteredPosts = selectedCategory == .all 
                                ? posts 
                                : posts.filter { $0.category == selectedCategory }
                            
                            if filteredPosts.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray)
                                    Text("No posts yet")
                                        .foregroundStyle(.gray)
                                    Text("Be the first to share!")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                ForEach(filteredPosts) { post in
                                    PostCard(post: post)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.purple)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.trailing)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCreatePost) {
            NavigationStack {
                CreatePostView()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            loadPosts()
        }
        .refreshable {
            await loadPostsAsync()
        }
    }
    
    private func loadPosts() {
        Task {
            await loadPostsAsync()
        }
    }
    
    private func loadPostsAsync() async {
        isLoading = true
        do {
            let firebaseService = FirebaseService()
            posts = try await firebaseService.fetchPosts(category: selectedCategory == .all ? nil : selectedCategory)
        } catch {
            print("Error loading posts: \(error)")
        }
        isLoading = false
    }
}

struct CommunityGuidelinesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Community Guidelines")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text("This is a safe space for empathy and support. All posts are anonymous. Please be respectful and follow our moderation rules to ensure a positive environment for everyone.")
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple : Color(white: 0.15))
                )
        }
    }
}

struct PostCard: View {
    let post: Post
    @State private var careCount: Int
    @State private var isCared: Bool = false
    
    init(post: Post) {
        self.post = post
        _careCount = State(initialValue: post.careCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info
            HStack(spacing: 12) {
                // Anonymous User Icon
                Circle()
                    .fill(Color.purple)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: post.userIconType.systemImage)
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                    }
                
                Text("Anonymous Student")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundStyle(.gray)
                }
            }
            
            // Post Title
            Text(post.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            // Post Body
            Text(post.body)
                .font(.body)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            // Engagement Metrics
            HStack(spacing: 20) {
                Button(action: toggleCare) {
                    HStack(spacing: 6) {
                        Image(systemName: isCared ? "hand.raised.fill" : "hand.raised")
                            .foregroundStyle(.purple)
                            .font(.system(size: 16))
                        Text("\(careCount)")
                            .font(.subheadline)
                            .foregroundStyle(.purple)
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .foregroundStyle(.purple)
                        .font(.system(size: 16))
                    Text("\(post.commentCount)")
                        .font(.subheadline)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
    
    private func toggleCare() {
        isCared.toggle()
        careCount += isCared ? 1 : -1
        
        // Update in Firebase
        Task {
            do {
                let firebaseService = FirebaseService()
                try await firebaseService.updatePostCare(postId: post.id, increment: isCared ? 1 : -1)
            } catch {
                print("Error updating care: \(error)")
            }
        }
    }
}

