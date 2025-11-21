import SwiftUI
import FirebaseFirestore

struct PeerSupportView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedCategory: PostCategory = .all
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showMyPostsOnly = false
    @State private var selectedPost: Post?
    @State private var postsListener: ListenerRegistration?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("Peer Support")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Spacer()
                            Button(action: {
                                showMyPostsOnly.toggle()
                            }) {
                                Label(showMyPostsOnly ? "My Posts" : "All Posts", systemImage: showMyPostsOnly ? "person.fill.badge.plus" : "line.3.horizontal.decrease")
                                    .font(.caption)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(showMyPostsOnly ? Color.purple.opacity(0.3) : Color(white: 0.15))
                                    )
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
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
                                    Button {
                                        selectedPost = post
                                    } label: {
                                        PostCard(post: post)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Action Button
            // Floating button removed; creation handled via main Add tab
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedPost) { post in
            NavigationStack {
                PostDetailView(post: post, myAnonymousId: appState.peerSupportAnonId)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            startListening()
        }
        .onDisappear {
            postsListener?.remove()
            postsListener = nil
        }
        .refreshable {
            startListening()
        }
    }
    
    private var filteredPosts: [Post] {
        let baseCategoryFiltered: [Post]
        if selectedCategory == .all {
            baseCategoryFiltered = posts
        } else {
            baseCategoryFiltered = posts.filter { $0.category == selectedCategory }
        }
        if showMyPostsOnly {
            let anonId = appState.peerSupportAnonId
            return baseCategoryFiltered.filter { $0.userId == anonId }
        }
        return baseCategoryFiltered
    }
    
    private func startListening() {
        postsListener?.remove()
        isLoading = true
        postsListener = FirebaseService().observePosts { newPosts in
            DispatchQueue.main.async {
                self.posts = newPosts
                self.isLoading = false
            }
        }
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
            
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.caption)
                        .foregroundStyle(.purple)
                    Text("\(post.commentCount)")
                        .font(.caption)
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
}

