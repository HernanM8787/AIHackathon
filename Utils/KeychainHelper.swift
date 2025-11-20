import Foundation
import Security

struct KeychainHelper {
    private static let service = "com.aihackathon.biometric"
    private static let credentialsAccount = "biometricCredentials"

    struct Credentials: Codable {
        let email: String
        let password: String
    }

    static func saveCredentials(email: String, password: String) {
        let credentials = Credentials(email: email, password: password)
        guard let data = try? JSONEncoder().encode(credentials) else { return }
        save(data, account: credentialsAccount)
    }

    static func loadCredentials() -> Credentials? {
        guard let data = read(account: credentialsAccount) else { return nil }
        return try? JSONDecoder().decode(Credentials.self, from: data)
    }

    static func deleteCredentials() {
        delete(account: credentialsAccount)
    }

    private static func save(_ data: Data, account: String) {
        delete(account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private static func read(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    private static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
