import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: LocalizedError {
    case emptyUsername
    case emptyEmail
    case weakPassword
    case usernameTaken
    case missingUser
    case incompleteProfile

    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Enter a username to continue."
        case .emptyEmail:
            return "Enter a valid email."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .usernameTaken:
            return "That username is already taken. Try another one."
        case .missingUser:
            return "Something went wrong. Please restart the app and sign in again."
        case .incompleteProfile:
            return "We couldn't find your profile. Please sign up again."
        }
    }
}

actor AuthService {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var cachedProfile: UserProfile?

    nonisolated var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    func restoreSession() async throws -> UserProfile? {
        if let profile = cachedProfile { return profile }
        guard let user = auth.currentUser else { return nil }
        if let profile = try await fetchProfile(for: user.uid) {
            cachedProfile = profile
            return profile
        }
        return nil
    }

    func userExists(for email: String) async throws -> Bool {
        let methods = try await auth.fetchSignInMethods(forEmail: email)
        return methods.isEmpty == false
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await auth.signIn(withEmail: email, password: password)
        guard let profile = try await fetchProfile(for: result.user.uid) else {
            throw AuthError.incompleteProfile
        }
        cachedProfile = profile
        return profile
    }

    func createAccount(email: String, password: String, username: String) async throws -> UserProfile {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedUsername.isEmpty == false else { throw AuthError.emptyUsername }
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmedEmail.isEmpty == false else { throw AuthError.emptyEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }

        let lower = trimmedUsername.lowercased()
        let usernameQuery = try await db.collection("users")
            .whereField("usernameLowercase", isEqualTo: lower)
            .getDocuments()
        if usernameQuery.isEmpty == false {
            throw AuthError.usernameTaken
        }

        let result = try await auth.createUser(withEmail: trimmedEmail, password: password)
        try await db.collection("users").document(result.user.uid).setData([
            "usernameLowercase": lower,
            "displayName": trimmedUsername,
            "email": trimmedEmail,
            "updatedAt": FieldValue.serverTimestamp()
        ])

        let profile = UserProfile.placeholder(id: result.user.uid, username: trimmedUsername, email: trimmedEmail)
        cachedProfile = profile
        return profile
    }

    func signOut() async throws {
        try auth.signOut()
        cachedProfile = nil
    }

    private func fetchProfile(for uid: String) async throws -> UserProfile? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let data = snapshot.data() else { return nil }
        guard let name = data["displayName"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        var profile = UserProfile.placeholder(id: uid, username: name, email: email)
        profile.academicLevel = data["academicLevel"] as? String
        profile.major = data["major"] as? String
        return profile
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        guard let user = auth.currentUser else { throw AuthError.missingUser }
        var updateData: [String: Any] = [
            "displayName": profile.displayName,
            "email": profile.email,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let academicLevel = profile.academicLevel {
            updateData["academicLevel"] = academicLevel
        }
        if let major = profile.major {
            updateData["major"] = major
        }
        try await db.collection("users").document(user.uid).updateData(updateData)
        cachedProfile = profile
    }
}
