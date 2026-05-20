import Foundation

@MainActor
final class PersistenceService {
    static let shared = PersistenceService()
    private let key = "uni_volunteer_activities"
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func save(_ activities: [ClubActivity]) throws {
        let data = try encoder.encode(activities)
        defaults.set(data, forKey: key)
    }

    func load() -> [ClubActivity] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try decoder.decode([ClubActivity].self, from: data)
        } catch {
            return []
        }
    }

    func hasExistingData() -> Bool {
        defaults.data(forKey: key) != nil
    }
}
