import Foundation

struct PermissionStorage {
    private let defaults = UserDefaults.standard
    private let key = "permission_state"

    func load() -> PermissionState {
        guard let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(PermissionState.self, from: data) else {
            return PermissionState()
        }
        return state
    }

    func save(_ state: PermissionState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}

