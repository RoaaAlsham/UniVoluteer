import SwiftUI

@Observable @MainActor
final class AppState {
    var currentUser: User?
    var selectedTab = 0
    var activities: [ClubActivity] = []

    var isLoggedIn: Bool { currentUser != nil }
    var isVolunteer: Bool { currentUser?.role == .volunteer }
    var isSupervisor: Bool { currentUser?.role == .supervisor }

    var currentUniversity: University? {
        guard let uid = currentUser?.universityId else { return nil }
        return ClubService.university(for: uid)
    }

    init() {
        activities = SeedDataService.seedIfNeeded()
    }

    func login(user: User) {
        currentUser = user
        selectedTab = 0
    }

    func logout() {
        currentUser = nil
        selectedTab = 0
    }

    func saveActivities() {
        try? PersistenceService.shared.save(activities)
    }

    func updateSkill(activityId: UUID, skillId: UUID, status: VerificationStatus, verifiedByUserId: UUID? = nil, verifiedByClubId: UUID? = nil) {
        guard let actIdx = activities.firstIndex(where: { $0.id == activityId }),
              let skillIdx = activities[actIdx].extractedSkills.firstIndex(where: { $0.id == skillId })
        else { return }
        activities[actIdx].extractedSkills[skillIdx].verificationStatus = status
        if status == .verified {
            activities[actIdx].extractedSkills[skillIdx].verifiedByUserId = verifiedByUserId
            activities[actIdx].extractedSkills[skillIdx].verifiedByClubId = verifiedByClubId
            activities[actIdx].extractedSkills[skillIdx].verifiedAt = Date()
        }
        saveActivities()
    }

    func renameSkill(activityId: UUID, skillId: UUID, newName: String) {
        guard let actIdx = activities.firstIndex(where: { $0.id == activityId }),
              let skillIdx = activities[actIdx].extractedSkills.firstIndex(where: { $0.id == skillId })
        else { return }
        activities[actIdx].extractedSkills[skillIdx].name = newName
        saveActivities()
    }
}
