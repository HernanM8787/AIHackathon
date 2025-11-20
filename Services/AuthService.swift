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
    case wrongPassword
    case accountNotFound
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Enter a username to continue."
        case .emptyEmail:
            return "Enter a valid email."
        case .weakPassword:
            return "Password must be at least 8 characters."
        case .usernameTaken:
            return "That username is already taken. Try another one."
        case .missingUser:
            return "Something went wrong. Please restart the app and sign in again."
        case .incompleteProfile:
            return "We couldn't find your profile. Please sign up again."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .accountNotFound:
            return "No account found with this email address."
        case .invalidEmail:
            return "Invalid email format. Please enter a valid email address."
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
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check if email is valid format
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            throw AuthError.invalidEmail
        }
        
        // Attempt to sign in and handle Firebase errors
        do {
            let result = try await auth.signIn(withEmail: trimmedEmail, password: password)
            guard let profile = try await fetchProfile(for: result.user.uid) else {
                throw AuthError.incompleteProfile
            }
            cachedProfile = profile
            return profile
        } catch let error as NSError {
            // Handle Firebase Auth errors
            let authErrorCode = AuthErrorCode(rawValue: error.code)
            
            switch authErrorCode {
            case .wrongPassword:
                throw AuthError.wrongPassword
            case .userNotFound:
                // Check if account exists with different method
                do {
                    let methods = try await auth.fetchSignInMethods(forEmail: trimmedEmail)
                    if methods.isEmpty {
                        throw AuthError.accountNotFound
                    } else {
                        throw AuthError.wrongPassword
                    }
                } catch let authError as AuthError {
                    throw authError
                } catch {
                    throw AuthError.accountNotFound
                }
            case .invalidEmail:
                throw AuthError.invalidEmail
            case .userDisabled:
                throw AuthError.accountNotFound
            default:
                // Check error message for more context
                let errorMessage = error.localizedDescription.lowercased()
                if errorMessage.contains("password") {
                    throw AuthError.wrongPassword
                } else if errorMessage.contains("user") || errorMessage.contains("not found") {
                    throw AuthError.accountNotFound
                } else {
                    throw AuthError.wrongPassword
                }
            }
        }
    }

    func createAccount(email: String, password: String, username: String, academicLevel: String? = nil, major: String? = nil) async throws -> UserProfile {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedUsername.isEmpty == false else { throw AuthError.emptyUsername }
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmedEmail.isEmpty == false else { throw AuthError.emptyEmail }
        guard password.count >= 8 else { throw AuthError.weakPassword }

        let lower = trimmedUsername.lowercased()
        let usernameQuery = try await db.collection("users")
            .whereField("usernameLowercase", isEqualTo: lower)
            .getDocuments()
        if usernameQuery.isEmpty == false {
            throw AuthError.usernameTaken
        }

        let result = try await auth.createUser(withEmail: trimmedEmail, password: password)
        var userData: [String: Any] = [
            "usernameLowercase": lower,
            "displayName": trimmedUsername,
            "email": trimmedEmail,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if let academicLevel = academicLevel {
            userData["academicLevel"] = academicLevel
        }
        if let major = major {
            userData["major"] = major
        }
        
        try await db.collection("users").document(result.user.uid).setData(userData)

        var profile = UserProfile.placeholder(id: result.user.uid, username: trimmedUsername, email: trimmedEmail)
        profile.academicLevel = academicLevel
        profile.major = major
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
        profile.biometricsEnabled = data["biometricsEnabled"] as? Bool ?? false
        profile.biometricDeviceID = data["biometricDeviceID"] as? String
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
        updateData["biometricsEnabled"] = profile.biometricsEnabled
        if let deviceID = profile.biometricDeviceID {
            updateData["biometricDeviceID"] = deviceID
        } else {
            updateData["biometricDeviceID"] = FieldValue.delete()
        }
        try await db.collection("users").document(user.uid).updateData(updateData)
        cachedProfile = profile
    }

    func updateBiometrics(enabled: Bool, deviceID: String?) async throws {
        guard let user = auth.currentUser else { throw AuthError.missingUser }
        var updateData: [String: Any] = [
            "biometricsEnabled": enabled
        ]
        if let deviceID {
            updateData["biometricDeviceID"] = deviceID
        } else {
            updateData["biometricDeviceID"] = FieldValue.delete()
        }
        try await db.collection("users").document(user.uid).updateData(updateData)
        cachedProfile?.biometricsEnabled = enabled
        cachedProfile?.biometricDeviceID = deviceID
    }
}
